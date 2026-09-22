using System;
using ProjectHub.Api.Models;

namespace ProjectHub.Api.Extensions;

public static class TaskEnumExtensions
{
    public static TaskItemStatus ToTaskItemStatus(this string? statusStr, TaskItemStatus defaultStatus = TaskItemStatus.Backlog)
    {
        if (string.IsNullOrWhiteSpace(statusStr))
        {
            return defaultStatus;
        }

        return Enum.TryParse<TaskItemStatus>(statusStr.Trim(), ignoreCase: true, out var status)
            ? status
            : defaultStatus;
    }

    public static TaskItemPriority ToTaskItemPriority(this string? priorityStr, TaskItemPriority defaultPriority = TaskItemPriority.Medium)
    {
        if (string.IsNullOrWhiteSpace(priorityStr))
        {
            return defaultPriority;
        }

        return Enum.TryParse<TaskItemPriority>(priorityStr.Trim(), ignoreCase: true, out var priority)
            ? priority
            : defaultPriority;
    }

    public static string ToWireString(this TaskItemStatus status) => status switch
    {
        TaskItemStatus.Backlog => "Backlog",
        TaskItemStatus.Todo => "Todo",
        TaskItemStatus.InProgress => "InProgress",
        TaskItemStatus.Review => "Review",
        TaskItemStatus.Done => "Done",
        _ => status.ToString()
    };

    public static string ToWireString(this TaskItemPriority priority) => priority switch
    {
        TaskItemPriority.Low => "Low",
        TaskItemPriority.Medium => "Medium",
        TaskItemPriority.High => "High",
        TaskItemPriority.Urgent => "Urgent",
        _ => priority.ToString()
    };
}

