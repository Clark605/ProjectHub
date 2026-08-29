using System.Collections.Generic;
using System.Threading.Tasks;
using ProjectHub.Api.DTOs.TaskDtos;

namespace ProjectHub.Api.Services.Interfaces;

public interface ITaskService
{
    Task<TaskResponseDto> CreateTaskAsync(string userId, int projectId, CreateTaskRequestDto request);
    Task<IEnumerable<TaskResponseDto>> GetTasksByProjectAsync(string userId, int projectId, string? status, string? assigneeId, string? priority);
    Task<TaskResponseDto> GetTaskByIdAsync(string userId, int taskId);
    Task<TaskResponseDto> UpdateTaskAsync(string userId, int taskId, UpdateTaskRequestDto request);
    Task DeleteTaskAsync(string userId, int taskId);
    Task<TaskResponseDto> UpdateTaskStatusAsync(string userId, int taskId, UpdateTaskStatusDto request);
    Task<TaskResponseDto> UpdateTaskAssigneeAsync(string userId, int taskId, UpdateTaskAssigneeDto request);
}

