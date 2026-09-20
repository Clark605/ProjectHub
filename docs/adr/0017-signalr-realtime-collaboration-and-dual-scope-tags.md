# Real-Time Push Synchronization, Online Presence, and Dual-Scope Tags

ProjectHub supersedes the interim focus-refresh and polling model (ADR-0009) by introducing real-time bidirectional push synchronization via ASP.NET Core SignalR, backed by Redis distributed pub/sub and in-memory sets for live online presence tracking. Concurrently, collaboration is extended with flat chronological Task Comments and a dual-scope Tag classification system.

### Architectural Decisions:

1. **SignalR Hub and Workspace Group Isolation**:
   The backend exposes a single authenticated hub (`WorkspaceHub`) mapped to `/api/v1/hubs/workspace`. Clients join and leave connection groups partitioned strictly by workspace ID (`workspace-{workspaceId}`). WebSocket handshakes authenticate via JWT bearer tokens passed as query parameters (`?access_token=...`) and validated by ASP.NET Core's `JwtBearerEvents.OnMessageReceived`.

2. **Scoped Mutation Event Broadcasting (Tier 1 & Tier 2)**:
   Service methods invoke `IHubContext<WorkspaceHub>` immediately following successful database commits and activity logging. Broadcasting is targeted to:
   - **Tier 1 (Board Mutations)**: `TaskCreated`, `TaskStatusChanged`, `TaskAssigned`, `TaskDeleted`.
   - **Tier 2 (Collaboration Mutations)**: `CommentAdded`, `CommentDeleted`.
   Concurrency continues to adhere to Last-Write-Wins (ADR-0009), with client-side optimistic UI reconciling immediately upon receiving broadcast events.

3. **Distributed Presence Tracking via Redis**:
   Active presence is managed through Redis Sets (`workspace:{workspaceId}:online_users`) storing active user identifiers. Presence joins and leaves are processed on `JoinWorkspace` and `OnDisconnectedAsync`. Built-in WebSocket ping/pong timeouts (30s) automatically trigger cleanup during abrupt client drops, broadcasting `PresenceChanged` payloads to all active workspace viewers.

4. **Dual-Scope Tag Model with Deterministic Color Hashing**:
   Tags (`Tag` entity) are owned by a workspace (`WorkspaceId`) with an optional project scope (`ProjectId?`):
   - *Workspace-level tags* (`ProjectId == null`): Created and deleted exclusively by the Workspace Owner; reusable across all projects in the workspace.
   - *Project-level tags* (`ProjectId != null`): Created and deleted by the Workspace Owner or Project Creator; scoped strictly to tasks within that project.
   Tag accent colors are deterministically generated on creation by hashing the tag name against a curated 12-color accessible palette, eliminating manual palette selection while guaranteeing high contrast in dark and light themes. Tasks enforce a server-side limit of at most 5 tags, and tag deletion cascades cleanly through join records (`TaskTag`) without deleting tasks.

5. **Flat Chronological Comments**:
   Task discussions are modeled as single-level flat chronological comments (`Comment` entity). Comments are editable only by their author and deletable by the author or Workspace Owner. Task payloads carry an aggregate `CommentCount` integer, surfaced as visual badges on Kanban cards.

6. **Client Architecture & Lifecycle Management**:
   In strict compliance with ADR-0016, real-time connectivity is managed by a singleton `SignalRService` registered in `get_it`. It supplies an `accessTokenFactory` wired to `AuthRepository` for silent token rotation on reconnect, and exposes domain streams that route-scoped feature Cubits (`KanbanCubit`, `CommentsCubit`) subscribe to and dispose of alongside screen lifecycles. Presence indicators are surfaced in the `Dashboard` workspace header and `KanbanAppBar`.

