using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ProjectHub.Api.DTOs.CommentDtos;
using ProjectHub.Api.Extensions;
using ProjectHub.Api.Services.Interfaces;

namespace ProjectHub.Api.Controllers;

[ApiController]
[Authorize]
public class CommentsController : ControllerBase
{
    private readonly ICommentService _commentService;

    public CommentsController(ICommentService commentService)
    {
        _commentService = commentService;
    }

    [HttpGet("api/v1/tasks/{taskId:int}/comments")]
    public async Task<IActionResult> GetComments(int taskId)
    {
        var userId = User.GetUserId();
        var comments = await _commentService.GetCommentsByTaskAsync(userId, taskId);
        return Ok(comments);
    }

    [HttpPost("api/v1/tasks/{taskId:int}/comments")]
    public async Task<IActionResult> CreateComment(int taskId, [FromBody] CreateCommentRequestDto request)
    {
        var userId = User.GetUserId();
        var comment = await _commentService.CreateCommentAsync(userId, taskId, request);
        return CreatedAtAction(nameof(GetComments), new { taskId }, comment);
    }

    [HttpPut("api/v1/comments/{id:int}")]
    public async Task<IActionResult> UpdateComment(int id, [FromBody] UpdateCommentRequestDto request)
    {
        var userId = User.GetUserId();
        var comment = await _commentService.UpdateCommentAsync(userId, id, request);
        return Ok(comment);
    }

    [HttpDelete("api/v1/comments/{id:int}")]
    public async Task<IActionResult> DeleteComment(int id)
    {
        var userId = User.GetUserId();
        await _commentService.DeleteCommentAsync(userId, id);
        return NoContent();
    }
}

