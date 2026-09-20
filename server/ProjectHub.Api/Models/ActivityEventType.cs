namespace ProjectHub.Api.Models;

public enum ActivityEventType
{
    WorkspaceCreated,
    WorkspaceUpdated,
    MemberAdded,
    MemberRemoved,
    ProjectCreated,
    ProjectStatusChanged,
    ProjectArchived,
    TaskCreated,
    TaskUpdated,
    TaskStatusChanged,
    TaskAssigned,
    TaskDeleted
}
