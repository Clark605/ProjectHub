# Workspace-Scoped My Tasks Aggregation Endpoint

To power the personal focus view ("My Tasks") across all projects within an active workspace, the API provides a dedicated aggregate endpoint (GET /workspaces/{id}/my-tasks) rather than performing client-side fan-out queries across every individual project. This ensures a single indexed database query (WHERE Project.WorkspaceId == @id AND AssigneeId == @userId), eliminates client-side N+1 round trips, preserves the workspace tenancy security boundary, and minimizes mobile network payload consumption.
