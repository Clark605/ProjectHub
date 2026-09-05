# Dedicated PATCH Endpoints for Kanban Status and Assignee

Kanban column drag-and-drop operations and task reassignments use dedicated minimal endpoints (`PATCH /tasks/{id}/status` and `PATCH /tasks/{id}/assignee`), while full detail modifications use `PUT /tasks/{id}`. `UpdateTaskRequestDto` (PUT) intentionally excludes `Status` to prevent race conditions and accidental status overwrites during general edits, while the dedicated PATCH endpoints minimize payload size and optimize direct manipulation in the Flutter UI.

