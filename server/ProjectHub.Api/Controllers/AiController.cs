using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using ProjectHub.Api.DTOs.AiDtos;
using ProjectHub.Api.Extensions;
using ProjectHub.Api.Services.Interfaces;

namespace ProjectHub.Api.Controllers;

[Route("api/v1/ai")]
[ApiController]
[Authorize]
public class AiController : ControllerBase
{
    private readonly IAiTextParser _aiTextParser;

    public AiController(IAiTextParser aiTextParser)
    {
        _aiTextParser = aiTextParser;
    }

    /// <summary>
    /// Parses transcribed voice/text input into a structured task draft using AI.
    /// Returns a draft that the client can display for user review before creating the task.
    /// </summary>
    [HttpPost("parse-task")]
    [EnableRateLimiting("AiParsePolicy")]
    public async Task<IActionResult> ParseTask(AiParseTaskRequestDto request)
    {
        var userId = User.GetUserId();

        var draft = await _aiTextParser.ParseTaskFromTextAsync(
            callerUserId: userId,
            projectId: request.ProjectId,
            workspaceId: request.WorkspaceId,
            transcribedText: request.Text,
            userLocalTime: request.UserLocalTime);

        return Ok(draft);
    }
}
