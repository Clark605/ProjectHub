# Workspace Owner Single Source of Truth

Workspace ownership is determined exclusively by `WorkspaceMember.Role == "Owner"` rather than maintaining an `OwnerId` foreign key on the `WorkSpace` entity. Having a separate `OwnerId` field alongside a `WorkspaceMember` row creates dual sources of truth that can fall out of synchronization. Workspace creation atomically creates the workspace and the owner's `WorkspaceMember` record within a single database transaction.

