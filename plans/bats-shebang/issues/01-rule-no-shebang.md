## TLDR

Add a `noShebang` bats-lint custom rule that flags any `#!` on line 1 of a `.bats` file.

## What to build

Create a new bats-lint custom rule `batsLintRule_noShebang` that inspects line 1 of a `.bats` file. If the line starts with `#!`, it emits one `noShebang` violation. Any shebang pattern is flagged — not just `#!/usr/bin/env bats`.

Wire the rule into the `bats-lint-custom` orchestrator following the existing pattern: source the rule file, then register the function name with `lint-custom-run`.

Write a test file for the rule (no shebang on the test file itself) using the `rules-helper` library (`run_rule`, `expect_rule_violation`, `expect_clean`).

Prior art: `rule-no-top-level-var.zsh` + its test file.

## Behavioral Tests

**Violation detected:**
- File with `#!/usr/bin/env bats` on line 1 emits a `noShebang` violation at line 1
- File with `#!/bin/sh` on line 1 emits a `noShebang` violation at line 1

**No violation:**
- File with no shebang produces no violation and exits 0
- File with `# not a shebang` on line 1 produces no violation
- File where `#!/usr/bin/env bats` appears on line 2 (not line 1) produces no violation

## Acceptance criteria

- [ ] `rule-no-shebang.zsh` exists and exports `batsLintRule_noShebang`
- [ ] `rule-no-shebang.bats` exists with no shebang, covers all behavioral test cases above
- [ ] `bats-lint-custom.zsh` sources and registers `batsLintRule_noShebang`
- [ ] `bats-lint rule-no-shebang.bats` passes
- [ ] `bats-lint bats-lint-custom.bats` still passes
