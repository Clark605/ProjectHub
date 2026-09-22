# Enum Schema Migration, Atomic Task Creation, and Resilient Multi-Tier Caching

ProjectHub refines database efficiency, mutation correctness, and caching resilience across the API service layer. This ADR supersedes raw string status and priority fields with typed PostgreSQL `smallint` enums, establishes strict atomicity for task and tag creation, formalizes multi-instance Redis startup tolerance, and guarantees immediate permission revocation through targeted cache invalidation.

### Architectural Decisions:

1. **Database Enum Storage as `smallint` with Over-the-Wire String Preservation**:
   - `Task.Status` and `Task.Priority` are modeled as C# enums (`TaskItemStatus`, `TaskItemPriority`) and mapped to PostgreSQL `smallint` (2 bytes) via EF Core value conversion (`.HasConversion<short>()`).
   - A composite index is defined on `(ProjectId, Status)`. By switching from `varchar(50)` to `smallint`, index storage is reduced by over 80% and query plans perform index seeks without requiring expression-based `LOWER()` indexing.
   - To preserve 100% backward compatibility for the Flutter client and avoid generic model-binding deserialization errors, all external HTTP DTOs (`TaskResponseDto`, `CreateTaskRequestDto`, `UpdateTaskRequestDto`, `UpdateTaskStatusDto`) strictly preserve `string` properties. Conversions are centralized in `TaskEnumExtensions`.

2. **Atomic Task Creation and Pre-Save Tag Resolution**:
   - Tag validation occurs strictly before any entity is attached to EF Core's change tracker.
   - A maximum of 5 tags is enforced at the validation layer via FluentValidation (`CreateTaskRequestDtoValidator`).
   - `TaskService.CreateTaskAsync` compares the count of resolved tags against the count of requested distinct tag IDs. If any tag is missing, deleted, or belongs to a different project/workspace, the request is rejected with HTTP 400 Bad Request, identifying the specific offending IDs.
   - Resolved tags are attached directly to `task.TaskTags` in memory, committing both the parent task and join entities in a single `SaveChangesAsync()` call wrapped within an implicit database transaction.

3. **Startup Resilience for Multi-Instance Redis & SignalR**:
   - Redis connectivity options configure `AbortOnConnectFail = false` with bounded timeouts (`ConnectTimeout = 2000ms`, `SyncTimeout = 1000ms`).
   - Connection initialization in `Program.cs` is performed asynchronously via `await ConnectionMultiplexer.ConnectAsync(redisOptions)`, preventing synchronous thread-pool starvation during application boot.
   - Both `HybridCache` and the SignalR backplane (`AddStackExchangeRedis`) consume this shared resilient configuration, allowing the API process to boot and serve traffic even during a total Redis blackout.

4. **Component-Level Observable Health Reporting**:
   - The diagnostic route `/api/v1/health` inspects live connectivity across all dependent infrastructure.
   - Component status is distinguished:
     - PostgreSQL up, Redis up $\rightarrow$ `200 OK` (`"status": "Healthy"`)
     - PostgreSQL up, Redis down $\rightarrow$ `200 OK` (`"status": "Degraded"`, `"redis": "Degraded (L1 Fallback)"`)
     - PostgreSQL down $\rightarrow$ `503 Service Unavailable` (`"status": "Unhealthy"`)
   - `IConnectionMultiplexer.IsConnected` is used exclusively as a monitoring probe, not a runtime request-routing gate.

5. **Role-Based Cache Invalidation and Hot-Path Read Caching**:
   - Workspace membership roles are cached with compound tags `user:{userId}:roles` and `workspace:{workspaceId}:members`.
   - To eliminate permission leaks, synchronous cache busting is enforced across all member lifecycle events: removal (`RemoveMemberFromWorkspaceAsync`), role changes (`UpdateMemberRoleAsync`), member additions (`AddMemberToWorkspaceAsync`), and workspace deletion (`DeleteWorkspaceAsync`).
   - Kanban board reads (`GetTasksByProjectAsync`) and focus views (`GetMyTasksAsync`) are cached via `HybridCache`, with tag invalidation wired into all task mutation endpoints (`Create`, `Update`, `UpdateStatus`, `UpdateAssignee`, `Delete`, `AttachTag`, `DetachTag`).

