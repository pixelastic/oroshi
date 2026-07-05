## Guidance

**Goal:** Add a Ralph plan progress segment to `tools/ai/claude/config/statusline`, displayed after MCP servers.

**Testing**
- Run tests: `bats tools/ai/claude/config/__tests__/statusline.bats`
- Lint zsh: `zsh-lint tools/ai/claude/config/statusline`
- Lint bats: `bats-lint tools/ai/claude/config/__tests__/statusline.bats`

**Key files**
- `tools/ai/claude/config/statusline` — main script to edit
- `tools/ai/claude/config/__tests__/statusline.bats` — test file to extend
- `tools/term/zsh/config/prompt/git.zsh` (lines 198-227) — model for segment logic
- `scripts/bin/ai/ralph/plan-directory` — accepts explicit path arg; returns plan dir or empty
- `scripts/bin/ai/ralph/plan-progress` — accepts explicit plan dir arg; outputs `done▮total` or exits non-zero

**Conventions**
- Mock external collaborators with `bats_mock`, not filesystem state
- Two-step call pattern: `plan-directory "$currentDir"` first, guard on empty, then `plan-progress "$planDir"`
- Suppress stderr on both calls with `2>/dev/null`
- Use `local var="$(cmd)"` form; `local` masks exit codes, check result explicitly
- Color/icon keys: `ICONS[git-issue]`, `COLORS[git-issue]`, `COLORS[success]`

## Discoveries

### Issue 01 — Ralph plan progress segment
- Two-level nesting (outer guard + inner guard) must be flattened: use `&&` to conditionally populate a `local planProgress=""` var, then a single `if` for rendering.
- `local planProgress=""` followed by a bare assignment is acceptable — the `local`/assignment split rule only applies to command substitutions, not subsequent conditional updates of an already-declared local.
- `plan-directory` mock belongs in `setup()` (default: returns empty) so existing tests remain unaffected; `plan-progress` only needs mocking in the tests that exercise plan rendering.
- Icon key in `icons-load-definitions` mock must match the script's lookup key exactly: `ICONS[claude-mcp-context7]`, not `ICONS[mcp-context7]`.
- `--dry-run` should use `currentDir="$PWD"` and read `modelName` from `~/.claude/settings.json` (`.model` field) — only tokens and cost are fake since they require a live session.
