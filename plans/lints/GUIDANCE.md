## Guidance

This PRD renames `zshlint` → `zsh-lint` (and sub-scripts) to align with the `{lang}-lint` naming convention used by all other linters in the repo.

**Testing commands:**
- Run zsh tests: `rtk bats <filepath>`
- Lint zsh files: `zsh-lint <filepath>` (after issue 01 is done; use `zshlint` before)

**Key file locations:**
- Core scripts: `scripts/bin/zsh/zshlint/` (→ `zsh-lint/` after issue 01)
- Rule files: `scripts/bin/zsh/zshlint/__rules/`
- Orchestrator tests: `scripts/bin/zsh/zshlint/__tests__/`
- Rule tests: `scripts/bin/zsh/zshlint/__rules/__tests__/`
- NeoVim config: `tools/vim/nvim/config/config/filetypes/zsh.lua` and `plugins/enabled/code-quality.lua`
- Claude hooks: `tools/ai/claude/config/hooks/allowlist.json`
- zsh-writer skill: `tools/ai/claude/config/skills/zsh-writer/SKILL.md`

**Conventions:**
- All 12 custom rule functions must use the `zshLintRule_*` prefix (camelCase, capital L)
- Inline suppression syntax is `# zsh-lint-disable <ruleCode>` on the line above the violation
- No tests for config/doc-only changes (allowlist, SKILL.md, CLAUDE.md, NeoVim lua)

**Prior art:**
- Rule test structure: `scripts/bin/zsh/zshlint/__rules/__tests__/rule-no-dash-n.bats`
- Orchestrator test structure: `scripts/bin/zsh/zshlint/__tests__/zshlint.bats`
- Similar linter for reference: `scripts/bin/vim/lua/` (lua-lint-custom, lua-lint-selene)

## Discoveries

<!-- Agents append findings here after each issue -->
