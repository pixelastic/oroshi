## Guidance

- Language: zsh scripts (shebang `#!/usr/bin/env zsh`, `set -e`) and autoload functions (`setopt local_options err_return`)
- Test: `bats <filepath>`
- Lint: `zshlint <filepath>`
- Skills are markdown files at `tools/ai/claude/config/skills/<name>/SKILL.md`
- Skill references are at `tools/ai/claude/config/skills/<name>/references/`
- Shell scripts live in `scripts/bin/ai/ralph/` (ralph-*) and `scripts/bin/ai/prd/` (prd-*)
- Autoload functions live in `tools/term/zsh/config/functions/autoload/`
- Prompt functions live in `tools/term/zsh/config/prompt/git.zsh`
- Use `jo` for JSON output in zsh scripts
- Use `jq` for JSON parsing in zsh scripts
- The UTF-8 separator between done/total in progress output is `▮` — Edit tool may not see it, use caution
- Prior art for bats tests: `scripts/bin/ai/ralph/__tests__/ralph-progress.bats`
- This is a bootstrapping PRD: the plans/ structure we're building is the same structure this PRD lives in

## Discoveries
