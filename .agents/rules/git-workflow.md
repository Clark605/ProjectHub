---
trigger: always_on

---

# Git Feature Branch Workflow Rules

1. **Never Commit Directly to `main`**: All feature development, refactorings, UI adjustments, and code changes MUST take place on dedicated feature branches (e.g. `feature/app-shell-navigation`, `feature/workspaces-management`, `feature/projects-management`, etc.).
2. **Divide into Commits**: If a feature requires multiple changes, divide the work into multiple commits with clear and descriptive commit messages. Each commit should represent a single logical change or improvement.
3. **Branch Lifecycle**:
   - Create a feature branch before making any code modifications.
   - Run verification (`flutter analyze`, `flutter test`, `dotnet build`) on the feature branch.
   - **Strict Commit Message Compliance**: When creating or proposing any git commits, ALWAYS follow the commit message format specified in [`.agents/rules/copilot-commit-message-instructions.md`](./copilot-commit-message-instructions.md) (explicit `server/` or `client/` in title/scope, imperative mood, 72-char limit, structured bullet details).
   - Only merge to `main` when the feature milestone is fully completed and approved.

