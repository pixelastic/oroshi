## TLDR

Add a Ralph plan progress segment to the Claude Code status line, with bats tests.

## What to build

Add a new segment to the statusline script, positioned after MCP servers. The segment resolves the plan directory for the current workspace (using the workspace dir from stdin), reads done/total progress, and displays `icon done/total`. Color is amber when in progress, green when done equals total. Silently omitted when no plan is active or state.json is absent/malformed.

TDD order: write the three failing tests first, then implement the segment to make them pass.

The bats setup stubs for `colors-load-definitions` and `icons-load-definitions` must be extended to include `COLORS[git-issue]`, `COLORS[success]`, and `ICONS[git-issue]`. Both `plan-directory` and `plan-progress` are mocked as external collaborators via `bats_mock`.

Prior art for the segment logic: `oroshi-prompt-populate:git_plan_progress` in `tools/term/zsh/config/prompt/git.zsh`.

## Behavioral Tests

**In-progress plan**
- Shows `icon done/total` in the output when plan is active and not yet complete

**Complete plan**
- Shows green color (COLORS[success]) when done equals total

**No plan**
- Segment is absent from output when `plan-directory` returns empty

## Acceptance criteria

- [ ] Segment appears after MCP servers when a plan is active
- [ ] Displays `icon done/total` format using `ICONS[git-issue]`
- [ ] Amber color (`COLORS[git-issue]`) when done < total
- [ ] Green color (`COLORS[success]`) when done == total
- [ ] Segment silently absent when no plan (plan-directory returns empty)
- [ ] Stderr suppressed on both external calls
- [ ] All three bats tests pass
