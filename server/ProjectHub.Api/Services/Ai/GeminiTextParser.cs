using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.EntityFrameworkCore;
using ProjectHub.Api.Data;
using ProjectHub.Api.DTOs.AiDtos;
using ProjectHub.Api.Services.Interfaces;

namespace ProjectHub.Api.Services.Ai;

/// <summary>
/// Gemini Flash implementation of <see cref="IAiTextParser"/>.
/// Uses the Gemini REST API with structured JSON output for reliable field extraction.
/// </summary>
public class GeminiTextParser : IAiTextParser
{
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly IConfiguration _configuration;
    private readonly AppDbContext _dbContext;
    private readonly ILogger<GeminiTextParser> _logger;

    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull
    };

    public GeminiTextParser(
        IHttpClientFactory httpClientFactory,
        IConfiguration configuration,
        AppDbContext dbContext,
        ILogger<GeminiTextParser> logger)
    {
        _httpClientFactory = httpClientFactory;
        _configuration = configuration;
        _dbContext = dbContext;
        _logger = logger;
    }

    public async Task<AiParsedTaskDraftDto> ParseTaskFromTextAsync(
        string callerUserId,
        int projectId,
        int workspaceId,
        string transcribedText,
        DateTimeOffset userLocalTime)
    {
        // 1. Fetch workspace members for assignee resolution context
        var members = await _dbContext.WorkspaceMembers
            .Where(wm => EF.Property<int>(wm, "WorkspaceId") == workspaceId)
            .Join(_dbContext.Users,
                wm => wm.UserId,
                u => u.Id,
                (wm, u) => new { u.Id, u.Name })
            .ToListAsync();

        // 2. Fetch project name for context
        var projectName = await _dbContext.Projects
            .Where(p => p.Id == projectId)
            .Select(p => p.Name)
            .FirstOrDefaultAsync() ?? "Unknown Project";

        // 3. Build the member context string
        var membersJson = JsonSerializer.Serialize(
            members.Select(m => new { id = m.Id, name = m.Name }),
            JsonOptions);

        // 4. Build the system prompt
        var systemPrompt = BuildSystemPrompt(projectName, projectId, callerUserId, userLocalTime, membersJson);

        // 5. Call Gemini API
        var result = await CallGeminiApiAsync(systemPrompt, transcribedText);

        // 6. Validate and sanitize the parsed result
        return SanitizeParsedDraft(result, members.Select(m => m.Id).ToHashSet());
    }

    private static string BuildSystemPrompt(
        string projectName,
        int projectId,
        string callerUserId,
        DateTimeOffset userLocalTime,
        string membersJson)
    {
        return $"""            
            You are a task parser for a project management app called ProjectHub.
            Given a user's spoken input, extract structured task fields.
            
            ## Context
            - Current project: "{projectName}" (ID: {projectId})
            - User's local time: {userLocalTime:O} (timezone offset: {userLocalTime.Offset})
            - The caller's userId is: "{callerUserId}" (map "assign to me", "my task", or "I'll do it" to this ID)
            - Workspace members: {membersJson}
            
            ## Output Rules
            - title: Concise action-oriented summary. Max 200 characters. Strip filler words.
            - description: Enhanced and structured. Format as:
              Line 1: One-sentence summary of the task context.
              Following lines: Markdown bullet points ("- ") for each distinct detail, action item, or requirement.
              Remove filler words (um, uh, like, you know), fix grammar, and deduplicate.
              If the user only gave a title-level sentence with no extra detail, return an empty string.
              Max 2000 characters.
            - priority: One of "Low", "Medium", "High", "Urgent". Default to "Medium" if not explicitly mentioned.
            - assigneeId: A userId from the workspace members list. Use null if not mentioned. Match fuzzy names.
            - assigneeName: The display name of the matched assignee. Use null if assigneeId is null.
            - dueDate: ISO 8601 UTC datetime string. Resolve relative dates ("tomorrow", "next Friday", "in 3 days")
              using the user's local time. Use null if no date/time was mentioned.
            - warnings: Array of strings for anything you couldn't confidently extract or if something was ambiguous.
              For example: "Could not match assignee 'the new guy' to any workspace member."
            
            ## Critical Rules
            - NEVER invent member IDs that are not in the workspace members list.
            - NEVER hallucinate dates. Only return a dueDate if the user explicitly mentioned a time reference.
            - If the input is unintelligible or too vague to extract a title, set title to the raw input text
              and add a warning: "Input was unclear. Please review the title."
            """;
    }

    private async Task<AiParsedTaskDraftDto> CallGeminiApiAsync(string systemPrompt, string userText)
    {
        var apiKey = _configuration["Ai:Gemini:ApiKey"]
            ?? throw new InvalidOperationException("Gemini API key is not configured. Set Ai:Gemini:ApiKey in configuration or GEMINI_API_KEY in .env.");

        var model = _configuration["Ai:Gemini:Model"] ?? "gemini-2.5-flash";
        var baseUrl = $"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={apiKey}";

        var requestBody = new
        {
            systemInstruction = new
            {
                parts = new[] { new { text = systemPrompt } }
            },
            contents = new[]
            {
                new
                {
                    parts = new[] { new { text = userText } }
                }
            },
            generationConfig = new
            {
                responseMimeType = "application/json",
                responseSchema = new
                {
                    type = "OBJECT",
                    properties = new Dictionary<string, object>
                    {
                        ["title"] = new { type = "STRING" },
                        ["description"] = new { type = "STRING" },
                        ["priority"] = new { type = "STRING", @enum = new[] { "Low", "Medium", "High", "Urgent" } },
                        ["assigneeId"] = new { type = "STRING", nullable = true },
                        ["assigneeName"] = new { type = "STRING", nullable = true },
                        ["dueDate"] = new { type = "STRING", nullable = true },
                        ["warnings"] = new { type = "ARRAY", items = new { type = "STRING" } }
                    },
                    required = new[] { "title", "description", "priority", "warnings" }
                },
                temperature = 0.1
            }
        };

        var jsonContent = JsonSerializer.Serialize(requestBody, JsonOptions);
        var httpContent = new StringContent(jsonContent, Encoding.UTF8, "application/json");

        var client = _httpClientFactory.CreateClient();
        client.Timeout = TimeSpan.FromSeconds(30);

        _logger.LogInformation("Calling Gemini API model {Model} for task parsing", model);

        var response = await client.PostAsync(baseUrl, httpContent);

        if (!response.IsSuccessStatusCode)
        {
            var errorBody = await response.Content.ReadAsStringAsync();
            _logger.LogError("Gemini API request failed with status {StatusCode}: {ErrorBody}",
                response.StatusCode, errorBody);
            throw new InvalidOperationException(
                $"AI service returned an error (HTTP {(int)response.StatusCode}). Please try again.");
        }

        var responseJson = await response.Content.ReadAsStringAsync();
        var geminiResponse = JsonSerializer.Deserialize<GeminiResponse>(responseJson, JsonOptions);

        var textContent = geminiResponse?.Candidates?.FirstOrDefault()?.Content?.Parts?.FirstOrDefault()?.Text;

        if (string.IsNullOrWhiteSpace(textContent))
        {
            _logger.LogWarning("Gemini API returned empty content for task parsing");
            throw new InvalidOperationException("AI service returned an empty response. Please try again.");
        }

        var parsed = JsonSerializer.Deserialize<AiParsedTaskDraftDto>(textContent, JsonOptions);

        return parsed ?? throw new InvalidOperationException(
            "AI service returned an unparseable response. Please try again.");
    }

    /// <summary>
    /// Validates and sanitizes the LLM output to prevent hallucinated data.
    /// </summary>
    private static AiParsedTaskDraftDto SanitizeParsedDraft(AiParsedTaskDraftDto draft, HashSet<string> validMemberIds)
    {
        var warnings = new List<string>(draft.Warnings);

        // Enforce title length
        if (draft.Title.Length > 200)
            draft.Title = draft.Title[..200];

        // Enforce description length
        if (draft.Description.Length > 2000)
            draft.Description = draft.Description[..2000];

        // Validate priority enum
        var validPriorities = new HashSet<string> { "Low", "Medium", "High", "Urgent" };
        if (!validPriorities.Contains(draft.Priority))
        {
            warnings.Add($"AI returned invalid priority '{draft.Priority}'. Defaulting to 'Medium'.");
            draft.Priority = "Medium";
        }

        // Validate assignee exists in workspace
        if (draft.AssigneeId is not null && !validMemberIds.Contains(draft.AssigneeId))
        {
            warnings.Add($"AI suggested assignee ID '{draft.AssigneeId}' which is not a valid workspace member. Clearing assignee.");
            draft.AssigneeId = null;
            draft.AssigneeName = null;
        }

        // Validate due date is not in the past (with 1-hour tolerance)
        if (draft.DueDate.HasValue && draft.DueDate.Value < DateTime.UtcNow.AddHours(-1))
        {
            warnings.Add("AI suggested a due date in the past. Clearing due date.");
            draft.DueDate = null;
        }

        draft.Warnings = warnings;
        return draft;
    }

    // --- Gemini REST API response models ---

    private sealed class GeminiResponse
    {
        public List<GeminiCandidate>? Candidates { get; set; }
    }

    private sealed class GeminiCandidate
    {
        public GeminiContent? Content { get; set; }
    }

    private sealed class GeminiContent
    {
        public List<GeminiPart>? Parts { get; set; }
    }

    private sealed class GeminiPart
    {
        public string? Text { get; set; }
    }
}
