# Git Feature Branch Workflow Rules

1. **Never Commit Directly to `main`**: All feature development, refactorings, UI adjustments, and code changes MUST take place on dedicated feature branches (e.g. `feature/app-shell-navigation`, `feature/workspaces-management`, `feature/projects-management`, etc.).
2.**Divide into Commits**: If a feature requires multiple changes, divide the work into multiple commits with clear and descriptive commit messages. Each commit should represent a single logical change or improvement. (for example, if you are implementing a new feature, you might have separate commits for "Updated the API service" "Add UI components", "Implement business logic", and "Write unit tests").
3. **Branch Lifecycle**:
   - Create a feature branch before making any code modifications.
   - Run verification (`flutter analyze`, `flutter test`, `dotnet build`) on the feature branch.
   - Commit changes with conventional commit messages on the feature branch.
   - Only merge to `main` when the feature milestone is fully completed and approved.

