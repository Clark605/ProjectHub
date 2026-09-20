using System;
using System.Collections.Generic;

namespace ProjectHub.Api.Models;

public class Tag
{
    public int Id { get; set; }
    public int WorkspaceId { get; set; }
    public WorkSpace Workspace { get; set; } = null!;
    public int? ProjectId { get; set; }
    public Project? Project { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Color { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<TaskTag> TaskTags { get; set; } = new List<TaskTag>();
}

