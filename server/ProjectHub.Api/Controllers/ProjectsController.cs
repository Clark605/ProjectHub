using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ProjectHub.Api.DTOs.ProjectDtos;
using ProjectHub.Api.DTOs.TaskDtos;
using ProjectHub.Api.Extensions;
using ProjectHub.Api.Services.Interfaces;

namespace ProjectHub.Api.Controllers
{
    [Route("api/v1/projects")]
    [ApiController]
    [Authorize]
    public class ProjectsController : ControllerBase
    {
        private readonly IProjectService _projectService;
        private readonly ITaskService _taskService;
        private readonly IActivityLogger _activityLogger;

        public ProjectsController(
            IProjectService projectService,
            ITaskService taskService,
            IActivityLogger activityLogger)
        {
            _projectService = projectService;
            _taskService = taskService;
            _activityLogger = activityLogger;
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetProject(int id)
        {
            var userId = User.GetUserId();
            var project = await _projectService.GetProjectByIdAsync(userId, id);
            return Ok(project);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateProject(int id, UpdateProjectRequestDto request)
        {
            var userId = User.GetUserId();
            var project = await _projectService.UpdateProjectAsync(userId, id, request);
            return Ok(project);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteProject(int id)
        {
            var userId = User.GetUserId();
            await _projectService.DeleteProjectAsync(userId, id);
            return NoContent();
        }

        [HttpGet("{id}/tasks")]
        public async Task<IActionResult> GetTasks(
            int id,
            [FromQuery] string? status,
            [FromQuery] string? assigneeId,
            [FromQuery] string? priority)
        {
            var userId = User.GetUserId();
            var tasks = await _taskService.GetTasksByProjectAsync(userId, id, status, assigneeId, priority);
            return Ok(tasks);
        }

        [HttpPost("{id}/tasks")]
        public async Task<IActionResult> CreateTask(int id, CreateTaskRequestDto request)
        {
            var userId = User.GetUserId();
            var task = await _taskService.CreateTaskAsync(userId, id, request);
            return CreatedAtAction("GetTask", "Tasks", new { id = task.Id }, task);
        }

        [HttpGet("{id}/activity")]
        public async Task<IActionResult> GetProjectActivity(int id, [FromQuery] int limit = 50)
        {
            var userId = User.GetUserId();
            await _projectService.GetProjectByIdAsync(userId, id);
            var activities = await _activityLogger.GetProjectActivitiesAsync(id, limit);
            return Ok(activities);
        }
    }
}
