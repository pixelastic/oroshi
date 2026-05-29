## Guidance

### Context

This PRD migrates all remaining consumers of the old project env var system (`PROJECT_<KEY>_*`, `PROJECTS_INDEX`, `env/projects.zsh`, `env/projects.json`) to the new system (`PROJECTS_V2` associative array loaded via `projects-load-definitions`, and `dist/projects.json` for non-ZSH tools). The migration ends with a rename of `PROJECTS_V2` → `PROJECTS`.

### Domain language

Use the vocabulary from `tools/term/zsh/config/functions/autoload/project/CONTEXT.md`:
- **Project** — a registered codebase with name, path, icon, color scheme
- **Context** — a Project + optional Worktree (where you are on the filesystem)
- **Context Badge** — the colored ANSI string rendered by `context-badge`
- **Context Root** / **Context Path** — functions that partition a path relative to the project root

### Key architecture decisions

- `projects-load-definitions` is the single entry point for loading `PROJECTS_V2` into memory. It is idempotent — always call it before accessing the array; never source `dist/projects.zsh` directly.
- `:icon` is the canonical key for project existence. A project without an icon (e.g. `dashboards`) is a color-only definition and is not considered a real project.
- `projects-load-definitions` is designed to be mocked in bats tests — define the function body to call `typeset -gA PROJECTS_V2` and populate the needed keys inside the mock. Do NOT set `PROJECTS_V2` before calling `bats_run_function`: ZSH associative arrays can't cross a subshell boundary.

### Testing

- **Run bats tests:** `bats <filepath>`
- **Lint ZSH:** `zshlint <filepath>`
- **Prior art for bats mocks:** `tools/term/zsh/config/functions/autoload/project/__tests__/context-root.bats`
- Only `project-exists` (issue 02) and `context-path.bats` (issue 06) require test work.

### What not to touch

- `projects-build` script — not modified in this PRD (only its output variable name changes in issue 10)
- `dist/projects.json` structure — not modified
- Neovim statusline — already uses the new system, no changes needed
- `context-root.bats` — already correct, no changes needed

### Deletion checklist (issue 09 prerequisite)

Before deleting the env infrastructure, confirm these are all done:
- Issue 05: `project-key` deleted (requires 02+03+04)
- Issue 07: `colors-refresh` no longer calls `env-generate-projects`
- Issue 08: Kitty Python reads `dist/projects.json`

## Discoveries

_Append-only. Add a new H3 block after each completed issue._

### Issue 06 — Rewrite context-path.bats

- `bats_mock` auto-initializes `$BATS_TMP_DIR` if not set (guard added to helper) — no need to call `bats_tmp_dir` in setup unless the test itself needs filesystem operations.
- When mocking the direct dependency (e.g. `context-root`), populating `PROJECTS_V2` is unnecessary — the mock short-circuits the entire lookup chain.

### Issue 02 — Migrate project-exists

- `typeset -gA PROJECTS_V2` must be inside the `projects-load-definitions()` mock body, not in the test body — ZSH associative arrays can't cross `bats_run_function`'s subshell boundary, so setting them before the call doesn't help.
