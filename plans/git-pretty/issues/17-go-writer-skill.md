## TLDR

Claude skill `go-writer` for TDD-driven Go development, mirroring python-writer.

## What to build

Skill at `tools/ai/claude/config/skills/go-writer/SKILL.md` with references:

### SKILL.md workflow

1. **Place the file** — packages in `scripts/bin/<name>/__lib/`, or wherever the project needs it
2. **TDD: write a failing test** — table-driven `*_test.go` in the same package, run `go-test <filepath>`
3. **Make it work** — minimal code to pass
4. **Refactor** — apply patterns from style.md, tests still pass
5. **Lint** — run `go-lint --fix <file>`, fix all remaining violations

### References

- `references/style.md`: return early, short functions, named return values only when clarifying, error handling with early returns, no bare `panic`
- `references/testing.md`: table-driven tests, test helper assertions, `t.Helper()`, subtests with `t.Run`

### Registration

- Add to `.claude/settings.json` skills list if needed
- Add trigger description: "Use when writing or modifying Go code"

## Acceptance criteria

- [ ] `go-writer` skill exists with SKILL.md and references
- [ ] Workflow follows TDD pattern (test → implement → refactor → lint)
- [ ] References document Go style conventions and testing patterns
- [ ] Skill is discoverable by Claude via description
