## Guidance

### Goal

Automate the sidequest launch flow: when the `/sidequest` skill finishes, a Worktree, Kitty tab, and Claude session are created automatically without user intervention.

### Testing commands

- Run bats tests: `bats <filepath>`
- Run zsh lint: `zsh-lint <filepath>`

### File locations

- New script: `scripts/bin/ai/sidequest/sidequest`
- Modified script: `scripts/bin/ai/sidequest/sidequest-end`
- Renamed script: `scripts/bin/kitty/kitty-run-claude` → `scripts/bin/kitty/kitty-helper-claude-start`
- Modified script: `scripts/bin/kitty/kitty-tab-create`
- Modified script: `scripts/bin/kitty/kitty-window-toggle-claude` (reference update only)
- Modified skill: `/home/tim/.claude/skills/sidequest/SKILL.md`
- Behavioral tests: `scripts/bin/ai/sidequest/__tests__/`
- Scaffolding tests: `plans/sidequest/scaffold/`

### Conventions

- Bin scripts use `#!/usr/bin/env zsh` with `set -e`
- Flags parsed with `zparseopts -E -D`
- Autoload zsh functions (e.g. `git-worktree-create`) are available in bin scripts via fpath set in `.zshenv`
- `git-worktree-create <slug>` cds into the Worktree — in a bin script this only affects the script's own process
- Worktree path: `$OROSHI_WORKTREES_DIR/<repo-name>--<slug>` (use `git-github-project-name` or folder name fallback for repo name)
- `kitty-tab-create` already supports `--focus` / `--keep-focus` and `--cwd`
- `kitty-window-create` already has `--cmd` support — use it as prior art for adding `--cmd` to `kitty-tab-create`
- Scaffolding tests live in `plans/sidequest/scaffold/` and are removed when the plan is archived

### Prior art

- Bats test pattern: `scripts/bin/ai/ralph/__tests__/ralph.bats`
- `--cmd` in kitty: `scripts/bin/kitty/kitty-window-create`
- Focus toggle: `scripts/bin/kitty/kitty-tab-create`

## Discoveries

(append-only — agents add findings here after each issue)

### Issue 02 — Add --cmd flag to kitty-tab-create

- `kitty@` was renamed to `kitty-remote` during this issue to make it mockable with `bats_mock` (which uses `declare -f` and can't handle `@` in identifiers). All 16 callers in `scripts/bin/kitty/` and the keybinding were updated.
