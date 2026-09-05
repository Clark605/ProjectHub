# Strict Read-Only Freeze for Archived Projects

When a Project's status is updated to `Archived`, the project and all of its associated tasks are strictly frozen as read-only. Task creation, detail edits, deletion, assignment changes, and Kanban status drag-and-drop are rejected on both the server API and client UI until the project is explicitly restored to `Active` or `Planning`. This guarantees that historical project data is preserved without unintended modifications.

