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
