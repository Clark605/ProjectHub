using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ProjectHub.Api.DTOs.TagDtos;
using ProjectHub.Api.Extensions;
using ProjectHub.Api.Services.Interfaces;

namespace ProjectHub.Api.Controllers;

[ApiController]
[Authorize]
public class TagsController : ControllerBase
{
    private readonly ITagService _tagService;

    public TagsController(ITagService tagService)
    {
        _tagService = tagService;
    }

    [HttpPost("api/v1/workspaces/{workspaceId:int}/tags")]
    public async Task<IActionResult> CreateWorkspaceTag(int workspaceId, [FromBody] CreateTagRequestDto request)
    {
        var userId = User.GetUserId();
        var tag = await _tagService.CreateWorkspaceTagAsync(userId, workspaceId, request);
        return Created($"api/v1/workspaces/{workspaceId}/tags", tag);
    }

    [HttpPost("api/v1/projects/{projectId:int}/tags")]
    public async Task<IActionResult> CreateProjectTag(int projectId, [FromBody] CreateTagRequestDto request)
    {
        var userId = User.GetUserId();
        var tag = await _tagService.CreateProjectTagAsync(userId, projectId, request);
        return Created($"api/v1/projects/{projectId}/tags", tag);
    }

    [HttpGet("api/v1/projects/{projectId:int}/available-tags")]
    public async Task<IActionResult> GetAvailableTags(int projectId)
    {
        var userId = User.GetUserId();
        var tags = await _tagService.GetAvailableTagsForProjectAsync(userId, projectId);
        return Ok(tags);
    }

    [HttpGet("api/v1/workspaces/{workspaceId:int}/tags")]
    public async Task<IActionResult> GetWorkspaceTags(int workspaceId)
    {
        var userId = User.GetUserId();
        var tags = await _tagService.GetWorkspaceTagsAsync(userId, workspaceId);
        return Ok(tags);
    }

    [HttpPost("api/v1/tasks/{taskId:int}/tags")]
    public async Task<IActionResult> AttachTag(int taskId, [FromBody] AttachTagRequestDto request)
    {
        var userId = User.GetUserId();
        var task = await _tagService.AttachTagToTaskAsync(userId, taskId, request.TagId);
        return Ok(task);
    }

    [HttpDelete("api/v1/tasks/{taskId:int}/tags/{tagId:int}")]
    public async Task<IActionResult> DetachTag(int taskId, int tagId)
    {
        var userId = User.GetUserId();
        var task = await _tagService.DetachTagFromTaskAsync(userId, taskId, tagId);
        return Ok(task);
    }

    [HttpDelete("api/v1/tags/{id:int}")]
    public async Task<IActionResult> DeleteTag(int id)
    {
        var userId = User.GetUserId();
        await _tagService.DeleteTagAsync(userId, id);
        return NoContent();
    }
}

