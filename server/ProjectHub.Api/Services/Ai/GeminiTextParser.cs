using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.EntityFrameworkCore;
using ProjectHub.Api.Data;
using ProjectHub.Api.DTOs.AiDtos;
using ProjectHub.Api.Exceptions;
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
        // 1. Validate project existence
        var project = await _dbContext.Projects
            .FirstOrDefaultAsync(p => p.Id == projectId)
            ?? throw new KeyNotFoundException($"Project with ID {projectId} not found.");

        // 2. Validate workspace ownership (IDOR check)
        if (project.WorkspaceId != workspaceId)
        {
            throw new ArgumentException($"Project with ID {projectId} does not belong to workspace {workspaceId}.");
        }

        // 3. Validate caller membership in the workspace containing this project
        var isMember = await _dbContext.WorkspaceMembers
            .AnyAsync(wm => wm.UserId == callerUserId && EF.Property<int>(wm, "WorkspaceId") == project.WorkspaceId);

        if (!isMember)
        {
            throw new ForbiddenException("You are not a member of the workspace containing this project.");
        }

        // 4. Fetch workspace members for assignee resolution context
        var members = await _dbContext.WorkspaceMembers
            .Where(wm => EF.Property<int>(wm, "WorkspaceId") == project.WorkspaceId)
            .Join(_dbContext.Users,
                wm => wm.UserId,
                u => u.Id,
                (wm, u) => new { u.Id, u.Name })
            .ToListAsync();

        var projectName = project.Name;

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

    private static readonly string[] FallbackModels =
    [
        "gemini-flash-lite-latest",
        "gemini-3.5-flash",
        "gemini-3.1-flash-lite",
        "gemini-3.8-flash"
    ];

    private async Task<AiParsedTaskDraftDto> CallGeminiApiAsync(string systemPrompt, string userText)
    {
        var apiKey = _configuration["Ai:Gemini:ApiKey"]
            ?? throw new InvalidOperationException("Gemini API key is not configured. Set Ai:Gemini:ApiKey in configuration or GEMINI_API_KEY in .env.");

        var configuredModel = _configuration["Ai:Gemini:Model"];
        var modelsToTry = new List<string>();

        if (!string.IsNullOrWhiteSpace(configuredModel))
        {
            modelsToTry.Add(configuredModel);
        }

        foreach (var m in FallbackModels)
        {
            if (!modelsToTry.Contains(m))
            {
                modelsToTry.Add(m);
            }
        }

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
        var client = _httpClientFactory.CreateClient();
        client.Timeout = TimeSpan.FromSeconds(30);

        string lastErrorBody = string.Empty;
        System.Net.HttpStatusCode lastStatusCode = System.Net.HttpStatusCode.InternalServerError;

        foreach (var model in modelsToTry)
        {
            var baseUrl = $"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={apiKey}";
            var httpContent = new StringContent(jsonContent, Encoding.UTF8, "application/json");

            _logger.LogInformation("Calling Gemini API model {Model} for task parsing", model);

            HttpResponseMessage response;
            try
            {
                response = await client.PostAsync(baseUrl, httpContent);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "HTTP call to Gemini model {Model} failed with exception", model);
                continue;
            }

            if (!response.IsSuccessStatusCode)
            {
                lastStatusCode = response.StatusCode;
                lastErrorBody = await response.Content.ReadAsStringAsync();
                _logger.LogWarning("Gemini API model {Model} failed with status {StatusCode}: {ErrorBody}",
                    model, response.StatusCode, lastErrorBody);

                // If model is not found (404) or busy (503/429), try next fallback model
                if (response.StatusCode == System.Net.HttpStatusCode.NotFound ||
                    response.StatusCode == System.Net.HttpStatusCode.ServiceUnavailable ||
                    (int)response.StatusCode == 429)
                {
                    continue;
                }

                // For auth or schema errors, stop trying
                throw new InvalidOperationException(
                    $"AI service returned an error (HTTP {(int)response.StatusCode}). Please try again.");
            }

            var responseJson = await response.Content.ReadAsStringAsync();
            var geminiResponse = JsonSerializer.Deserialize<GeminiResponse>(responseJson, JsonOptions);
            var textContent = geminiResponse?.GetFirstText();

            if (string.IsNullOrWhiteSpace(textContent))
            {
                _logger.LogWarning("Gemini API model {Model} returned empty content", model);
                continue;
            }

            var parsed = JsonSerializer.Deserialize<AiParsedTaskDraftDto>(textContent, JsonOptions);
            if (parsed is not null)
            {
                _logger.LogInformation("Successfully parsed task draft using Gemini model {Model}", model);
                return parsed;
            }
        }

        _logger.LogError("All Gemini model candidates failed. Last status {StatusCode}: {ErrorBody}",
            lastStatusCode, lastErrorBody);

        throw new InvalidOperationException(
            $"AI service returned an error (HTTP {(int)lastStatusCode}). Please try again.");
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

        public string? GetFirstText() =>
            Candidates?.FirstOrDefault()?.Content?.Parts?.FirstOrDefault()?.Text;
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
