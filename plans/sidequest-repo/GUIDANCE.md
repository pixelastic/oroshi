## Guidance

### Goal

Allow `sidequest` to target a different repo than the current CWD, and simplify the script surface by merging `sidequest-end` into `sidequest`.

### File locations

- Script: `scripts/bin/ai/sidequest/sidequest`
- Script (deleted): `scripts/bin/ai/sidequest/sidequest-end`
- Tests: `scripts/bin/ai/sidequest/__tests__/sidequest.bats`
- Tests (deleted): `scripts/bin/ai/sidequest/__tests__/sidequest-end.bats`
- Skill: `tools/ai/claude/config/skills/sidequest/SKILL.md`
- Allowlist: `tools/ai/claude/config/hooks/allowlist.json`

### Testing commands

```
bats scripts/bin/ai/sidequest/__tests__/sidequest.bats
zsh-lint scripts/bin/ai/sidequest/sidequest
bats-lint scripts/bin/ai/sidequest/__tests__/sidequest.bats
```

### Conventions

- ZSH scripts use `set -e` and `zparseopts` for flag parsing
- Bats tests use `bats_mock` to stub collaborators, `bats_run_zsh` to invoke scripts
- All test variables go inside `setup()`, not at file top level
- Use `[[ $isXxx == "1" ]]` for boolean flag tests, not `(( isXxx ))`
- Use `if/then/fi` for blocks with 2+ instructions; `&&` only for single-action one-liners
- Use `$OROSHI_ROOT` for oroshi paths, never hardcoded `~/.oroshi`

### Key collaborators in `sidequest`

- `git-directory-is-repository` — checks if CWD is a git repo (used to guard `--repo-dir`)
- `git-worktree-create <slug>` — creates the worktree from CWD's repo
- `git-worktree-path <slug>` — returns filesystem path of the created worktree
- `kitty-tab-create <title> --cwd <path> --cmd <cmd>` — opens the Kitty tab

### Skill edit rule

The skill lives in the worktree path (`tools/ai/claude/config/skills/sidequest/SKILL.md`). Never edit via the `~/.claude/skills/` symlink path.

### Repo resolution in skill

`project-path <name>` (zsh autoload) resolves a registered project name to its filesystem path. Returns exit 1 if unknown.

## Discoveries
