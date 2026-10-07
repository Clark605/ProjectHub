using System;
using System.Collections.Generic;
using ProjectHub.Api.DTOs.ActivityDtos;
using ProjectHub.Api.DTOs.TaskDtos;

namespace ProjectHub.Api.DTOs.DashboardDtos;

public class WorkspaceDashboardDto
{
    public int ActiveProjectsCount { get; set; }
    public int InProgressTasksCount { get; set; }
    public int UrgentTasksCount { get; set; }
    public int CompletedTasksCount { get; set; }
    public int OverdueTasksCount { get; set; }
    public int DueThisWeekTasksCount { get; set; }
    public List<TaskResponseDto> FocusTasks { get; set; } = [];
    public List<ActivityEventDto> RecentActivities { get; set; } = [];
}
