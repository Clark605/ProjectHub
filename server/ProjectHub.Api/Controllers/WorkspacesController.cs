using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ProjectHub.Api.DTOs.ProjectDtos;
using ProjectHub.Api.DTOs.WorkSpaceDtos;
using ProjectHub.Api.Extensions;
using ProjectHub.Api.Services.Interfaces;

namespace ProjectHub.Api.Controllers
{
    [Route("[controller]")]
    [ApiController]
    [Authorize]
    public class WorkspacesController : ControllerBase
    {
        private readonly IWorkspaceService _workspaceService;
        private readonly IProjectService _projectService;

        public WorkspacesController(
            IWorkspaceService workspaceService,
            IProjectService projectService)
        {
            _workspaceService = workspaceService;
            _projectService = projectService;
        }

        [HttpGet]
        public async Task<IActionResult> GetWorkspaces()
        {
            var userId = User.GetUserId();
            var workspaces = await _workspaceService.GetWorkspacesByUserIdAsync(userId);
            return Ok(workspaces);
        }

        [HttpPost]
        public async Task<IActionResult> CreateWorkspace(CreateWorkspaceRequestDto request)
        {
            var userId = User.GetUserId();
            var workspace = await _workspaceService.CreateWorkspaceAsync(userId, request);
            return CreatedAtAction(nameof(GetWorkspace), new { id = workspace.Id }, workspace);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetWorkspace(int id)
        {
            var userId = User.GetUserId();
            var workspace = await _workspaceService.GetWorkspaceByIdAsync(userId, id);
            return Ok(workspace);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateWorkspace(int id, UpdateWorkspaceRequestDto request)
        {
            var userId = User.GetUserId();
            var workspace = await _workspaceService.UpdateWorkspaceAsync(userId, id, request);
            return Ok(workspace);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteWorkspace(int id)
        {
            var userId = User.GetUserId();
            await _workspaceService.DeleteWorkspaceAsync(userId, id);
            return NoContent();
        }

        [HttpGet("{id}/members")]
        public async Task<IActionResult> GetMembers(int id)
        {
            var userId = User.GetUserId();
            var members = await _workspaceService.GetMembersByWorkspaceIdAsync(userId, id);
            return Ok(members);
        }

        [HttpPost("{id}/members")]
        public async Task<IActionResult> AddMember(int id, AddMemberDto request)
        {
            var userId = User.GetUserId();
            var member = await _workspaceService.AddMemberToWorkspaceAsync(userId, id, request);
            return Ok(member);
        }

        [HttpDelete("{id}/members/{userId}")]
        public async Task<IActionResult> RemoveMember(int id, string userId)
        {
            var currentUserId = User.GetUserId();
            await _workspaceService.RemoveMemberFromWorkspaceAsync(currentUserId, id, userId);
            return NoContent();
        }

        [HttpGet("{id}/projects")]
        public async Task<IActionResult> GetProjects(int id, [FromQuery] string? status)
        {
            var userId = User.GetUserId();
            var projects = await _projectService.GetProjectsByWorkspaceAsync(userId, id, status);
            return Ok(projects);
        }

        [HttpPost("{id}/projects")]
        public async Task<IActionResult> CreateProject(int id, CreateProjectRequestDto request)
        {
            var userId = User.GetUserId();
            var project = await _projectService.CreateProjectAsync(userId, id, request);
            return CreatedAtAction("GetProject", "Projects", new { id = project.Id }, project);
        }
    }
}
