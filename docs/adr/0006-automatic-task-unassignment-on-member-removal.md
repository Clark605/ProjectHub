# Automatic Task Unassignment on Member Removal

When a member is removed from a Workspace (`DELETE /workspaces/{id}/members/{userId}`), all tasks assigned to that user in that workspace are automatically unassigned (`AssigneeId = null`). This prevents orphan foreign key references to users who no longer have workspace access without blocking workspace administrative workflows.

