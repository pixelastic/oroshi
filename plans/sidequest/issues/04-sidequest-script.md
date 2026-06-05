## TLDR

Create the `sidequest` orchestrator script with tests.

## What to build

Create `scripts/bin/ai/sidequest/sidequest` — the single entry point for launching a sidequest session:

```
sidequest <slug> [--prompt <value>] [--no-focus]
```

The script:
1. Creates a Worktree for the slug in the current repo via `git-worktree-create`
2. Derives the Worktree path from `$OROSHI_WORKTREES_DIR` and the Repo Name
3. Opens a Kitty tab titled `<slug>` pointing at the Worktree via `kitty-tab-create --cmd`
4. Passes `--prompt` to `kitty-helper-claude-start` when provided
5. Focuses the new tab by default; keeps current focus when `--no-focus` is passed

## Behavioral Tests

Mock immediate collaborators: `git-worktree-create`, `kitty-tab-create`, and `git-github-project-name` (or equivalent Repo Name resolver).

**Error handling**
- exits with an error when called with no slug

**Worktree creation**
- calls `git-worktree-create` with the slug

**Tab creation**
- calls `kitty-tab-create` with the slug as title and the Worktree path as cwd
- calls `kitty-tab-create` with `--cmd "kitty-helper-claude-start"` when no prompt is given
- calls `kitty-tab-create` with `--cmd "kitty-helper-claude-start @/path/to/file.md"` when `--prompt @/path/to/file.md` is given

**Focus behavior**
- calls `kitty-tab-create` without `--focus` when `--no-focus` is passed
- calls `kitty-tab-create` with `--focus` when `--no-focus` is not passed

## Acceptance criteria

- [ ] Script exists at `scripts/bin/ai/sidequest/sidequest`
- [ ] Test file exists at `scripts/bin/ai/sidequest/__tests__/sidequest.bats`
- [ ] All behavioral tests pass
- [ ] `sidequest fix-ralph` (no flags) creates Worktree and focused tab with no prompt
- [ ] `sidequest fix-ralph --prompt @/tmp/fix-ralph.md --no-focus` creates Worktree and background tab with prompt
