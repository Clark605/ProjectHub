using ProjectHub.Api.DTOs.AiDtos;

namespace ProjectHub.Api.Services.Interfaces;

/// <summary>
/// Provider-agnostic interface for parsing natural language text into structured task drafts.
/// </summary>
public interface IAiTextParser
{
    /// <summary>
    /// Parses transcribed voice/text input into a structured task draft using an LLM.
    /// </summary>
    /// <param name="callerUserId">The authenticated user's ID (for 'assign to me' resolution).</param>
    /// <param name="projectId">The target project ID.</param>
    /// <param name="workspaceId">The workspace ID (for member context).</param>
    /// <param name="transcribedText">The raw transcribed text from speech-to-text.</param>
    /// <param name="userLocalTime">The user's current local time with timezone offset.</param>
    /// <returns>A parsed task draft with extracted fields.</returns>
    Task<AiParsedTaskDraftDto> ParseTaskFromTextAsync(
        string callerUserId,
        int projectId,
        int workspaceId,
        string transcribedText,
        DateTimeOffset userLocalTime);
}
