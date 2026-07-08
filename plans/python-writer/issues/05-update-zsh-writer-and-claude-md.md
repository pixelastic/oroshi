## TLDR

Update `zsh-writer` Step 4 to use `zsh-lint --fix`, and refine the CLAUDE.md Python rule.

## What to build

### `tools/ai/claude/config/skills/zsh-writer/SKILL.md`

Update Step 4 — Lint:
- Change `zsh-lint <file>` → `zsh-lint --fix <file>`
- Same for bats lint: `bats-lint <file>` stays unchanged (no --fix for bats-lint)

### `tools/ai/claude/config/CLAUDE.md`

Split the current rule:
> `NEVER: Never suggest to write a script in python.`

Into two:
> `NEVER: Never propose Python as the implementation language for a new script — prefer ZSH or JavaScript.`
> `DO: When Python is explicitly requested or when modifying existing Python files, use python-writer.`

## Acceptance criteria

- [ ] `zsh-writer` Step 4 uses `zsh-lint --fix <file>` for `.zsh` files
- [ ] `zsh-writer` checklist updated to reference `zsh-lint --fix`
- [ ] CLAUDE.md no longer has the blanket "Never suggest python" formulation
- [ ] CLAUDE.md has the "never propose" rule and the "use python-writer" rule as two distinct entries
