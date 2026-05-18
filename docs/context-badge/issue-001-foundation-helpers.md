## PRD

`docs/context-badge/PRD.md`

## What to build

Three new autoload functions in the `project` domain:

- **`context-project <path>`** — resolves a filesystem path to a registered project name. Replaces `project-by-path`. Returns empty string if the path belongs to no known project.
- **`context-root <path>`** — returns the Context Root for a path: the Worktree root if the path is inside a linked Worktree, otherwise the Project root. Returns empty string if the path belongs to no known project. Detects worktree status live via git commands (not cached env vars).
- **`context-path <path>`** — returns the path relative to the Context Root (strips the Context Root prefix). Does not simplify — callers that want a simplified path call `simplify-path` on the result.

Write BATS tests covering all three functions: project resolution, root detection (worktree vs non-worktree), path stripping, and empty-string edge cases.

## Acceptance criteria

- [ ] `context-project` returns the project name for a path inside a registered project
- [ ] `context-project` returns empty string for a path outside all registered projects
- [ ] `context-root` returns the Worktree root when given a path inside a linked Worktree
- [ ] `context-root` returns the Project root when given a path inside a project but not a Worktree
- [ ] `context-root` returns empty string for a path outside all known projects
- [ ] `context-path` returns the sub-path relative to the Context Root (no leading slash)
- [ ] All acceptance criteria covered by BATS tests

## Blocked by

None — can start immediately.
