# ProjectHub

ProjectHub is a collaborative project and task management platform that helps teams organize workspaces, manage projects, and track tasks visually on Kanban boards.

## Language

### Core Entities

**Workspace**:
The top-level organizational and security boundary that contains projects and members.
_Avoid_: Organization, team, account, group

**Accent Color**:
A workspace-owned color from a fixed palette of 10 vetted accents, set by the workspace Owner and visible to all members. Used exclusively as a wayfinding signal on workspace switcher indicators, sidebar headers, and workspace list markers. Not a theme — does not affect buttons, cards, backgrounds, or semantic status colors.
_Avoid_: Theme, palette, brand color, workspace color

**Member**:
A user who belongs to a workspace with an assigned role (`Owner` or `Member`).
_Avoid_: User, collaborator, participant

**Project**:
A scoped initiative within a workspace containing tasks and tracked across its lifecycle. Project membership is implicitly open to all members of the parent workspace.
_Avoid_: Board, repository, space

**Task**:
A distinct unit of actionable work within a project assigned to a workspace member and tracked on the Kanban board.
_Avoid_: Card, item, ticket, issue, todo

**Comment**:
A chronological textual remark or discussion entry attached to a task by a workspace member.
_Avoid_: Message, chat, note, reply

**Tag**:
A colored label attached to tasks for categorical filtering and classification, scoped either to an entire workspace (cross-project) or to a specific project.
_Avoid_: Label, category, badge, flag, topic

### Roles & Ownership

**Role**:
The authorization designation of a Member within a Workspace (`Owner` or `Member`).
_Avoid_: Permission level, user type, rank

**Creator**:
The member who authored a workspace, project, or task.
_Avoid_: Author, submitter, originator

**Assignee**:
The workspace member responsible for executing a specific task.
_Avoid_: Owner, worker, handler

### Lifecycle & Workflows

**Project Status**:
The lifecycle state of a project (`Planning`, `Active`, `Completed`, `Archived`). When archived, the project and all its tasks are strictly read-only.
_Avoid_: Phase, stage

**Task Status**:
The workflow stage of a task represented as a Kanban column (`Backlog`, `Todo`, `InProgress`, `Review`, `Done`).
_Avoid_: Step, state, column

**Priority**:
The urgency level assigned to a task (`Low`, `Medium`, `High`, `Urgent`).
_Avoid_: Severity, importance

**Due Date**:
The target completion timestamp assigned to a project or task.
_Avoid_: Deadline, target date, expiry

**Kanban Board**:
The visual representation of a project's tasks grouped into fixed 5-stage status columns, supporting user-configured filtering and sorting.
_Avoid_: Workflow board, taskboard, scrum board

**My Tasks**:
The personalized focus view aggregating a member's assigned tasks across all projects within an active workspace, categorized into urgency groups.
_Avoid_: User tasks, assigned list, personal board

**Presence**:
The real-time status indicating workspace members actively connected and viewing a workspace session.
_Avoid_: Active status, online status, ping, watcher

