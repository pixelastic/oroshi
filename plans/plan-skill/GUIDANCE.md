## Guidance

- **Language**: ZSH for scripts, Markdown for skills
- **Testing**: `bats <filepath>` for ZSH scripts
- **Linting**: `zsh-lint <filepath>` for ZSH, `bats-lint <filepath>` for .bats
- **Existing tests**: `scripts/bin/ai/prd/__tests__/prd-end.bats` — migrate to `plan-start.bats`, don't rewrite from scratch
- **Script conventions**: `set -e` for scripts with shebang, `jo` for JSON output, `jq` for JSON parsing
- **Skill location**: `tools/ai/claude/config/skills/<name>/SKILL.md` with `references/` subdirectory
- **Reference templates**: commit-hint.md stays in `ralph/references/` (shared across skills), all other templates move to `plan/references/`
- **plan-start output**: `{ worktreePath, branch, planDir }` — 3 fields only, skill derives all paths from `planDir`

## Discoveries
