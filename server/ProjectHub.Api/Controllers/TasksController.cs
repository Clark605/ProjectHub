using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ProjectHub.Api.DTOs.TaskDtos;
using ProjectHub.Api.Extensions;
using ProjectHub.Api.Services.Interfaces;

namespace ProjectHub.Api.Controllers
{
    [Route("api/v1/tasks")]
    [ApiController]
    [Authorize]
    public class TasksController : ControllerBase
    {
        private readonly ITaskService _taskService;

        public TasksController(ITaskService taskService)
        {
            _taskService = taskService;
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetTask(int id)
        {
            var userId = User.GetUserId();
            var task = await _taskService.GetTaskByIdAsync(userId, id);
            return Ok(task);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateTask(int id, UpdateTaskRequestDto request)
        {
            var userId = User.GetUserId();
            var task = await _taskService.UpdateTaskAsync(userId, id, request);
            return Ok(task);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteTask(int id)
        {
            var userId = User.GetUserId();
            await _taskService.DeleteTaskAsync(userId, id);
            return NoContent();
        }

        [HttpPatch("{id}/status")]
        public async Task<IActionResult> UpdateTaskStatus(int id, UpdateTaskStatusDto request)
        {
            var userId = User.GetUserId();
            var task = await _taskService.UpdateTaskStatusAsync(userId, id, request);
            return Ok(task);
        }

        [HttpPatch("{id}/assignee")]
        public async Task<IActionResult> UpdateTaskAssignee(int id, UpdateTaskAssigneeDto request)
        {
            var userId = User.GetUserId();
            var task = await _taskService.UpdateTaskAssigneeAsync(userId, id, request);
            return Ok(task);
        }
    }
}

