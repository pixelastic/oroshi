## Execution order

0001 → start here, no blockers (first Custom Rule — tracer bullet)
0002 → needs 0001 (Orchestrator scaffold)
0003 → needs 0002 (independent of 0004–0008)
0004 → needs 0002 (independent of 0003, 0005–0008)
0005 → needs 0002 (independent of 0003–0004, 0006–0008)
0006 → needs 0002 (independent of 0003–0005, 0007–0008)
0007 → needs 0002 (independent of 0003–0006, 0008)
0008 → needs 0002 (independent of 0003–0007)

## Guidance

- **Read CONTEXT.md first** — `docs/zshlint/CONTEXT.md` defines the shared vocabulary (Custom Rule, Lib File, Orchestrator, Rule Output format). Use these terms throughout.
- **Start every rule issue with `grill-with-docs`** — before writing any code for a Custom Rule, run a grill-with-docs session to validate edge cases with the user.
- **Rule Output format**: `file▮code▮level▮line▮message` (▮ = U+25AE). One line per violation, empty output = no violation.
- **Lib File location**: `scripts/bin/zsh/zshlint/__rules/rule-{slug}.zsh`
- **Function naming**: `zshlintRule_{CamelCaseName}()`
- **Test file location**: `scripts/bin/zsh/zshlint/__tests__/rule-{slug}.bats`
- **Test helper**: load with `load '../../../__tests__/helper'` (relative path from `__tests__/` to `scripts/bin/__tests__/helper`)
- **Use `zsh-writer` skill** when writing ZSH code
- **Run `zshlint` on every file you write** — the linter must pass on its own source files

---

## Log (append below when an issue is completed)
