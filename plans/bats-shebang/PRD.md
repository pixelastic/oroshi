## Problem Statement

32 `.bats` test files carry a `#!/usr/bin/env bats` shebang on line 1. Shebangs exist to let a file be executed directly as a program, but `.bats` files are never invoked that way — they are always run via `bats <file>`. The shebang is therefore noise: it misleads readers, adds nothing, and (in 11 cases) is paired with a `+x` execute bit that is equally meaningless. There is also no lint rule to prevent the pattern from re-appearing in future files.

## Solution

Remove the shebang and execute bit from all affected `.bats` files, and add a `bats-lint` custom rule (`noShebang`) that flags any `.bats` file whose first line starts with `#!`. The rule is wired into the existing `bats-lint-custom` orchestrator so it runs automatically on every future lint pass. One stale test in `rule-no-top-level-var` that asserted shebangs were harmless is removed, since the scenario is now forbidden.

## User Stories

1. As a developer reading a `.bats` file, I want no shebang on line 1, so that I am not misled into thinking the file can be executed directly.
2. As a developer writing a new `.bats` file, I want `bats-lint` to flag a shebang immediately, so that the mistake is caught before commit.
3. As a developer running `bats-lint` on a clean file, I want the `noShebang` rule to produce no violations, so that clean files are not penalized.
4. As a developer running `bats-lint` on a file with a shebang, I want a `noShebang` violation with a clear message and the correct line number, so that I know exactly what to fix.
5. As a developer, I want all existing `.bats` files to pass `bats-lint` after the cleanup, so that the baseline is clean from the start.
6. As a developer, I want `.bats` files to have no execute bit, so that permissions reflect actual intent.

## Implementation Decisions

- **Mass cleanup:** Strip the shebang line (line 1 exactly matching `#!/usr/bin/env bats`) from all 32 `.bats` files. Remove the execute bit from the 11 that have it. No other content changes.
- **New rule — `noShebang`:** A custom bats-lint rule function `batsLintRule_noShebang(file)` that checks whether line 1 of the file starts with `#!`. If so, it emits one violation with code `noShebang`. The check is not anchored to `#!/usr/bin/env bats` specifically — any shebang on line 1 is a violation.
- **Rule registration:** The new rule is sourced and registered inside `bats-lint-custom` alongside existing rules, following the established pattern (source the rule file, then pass the function name to `lint-custom-run`).
- **Stale test removal:** The test case "no violation for shebang" in `rule-no-top-level-var` tests is removed. The `rule-no-top-level-var` rule itself is unchanged — its regex never matched shebangs anyway, making the test redundant even before this change.
- **No changes to zsh-writer reference docs:** The lint rule is the authoritative enforcement mechanism; a prose note in `testing.md` would duplicate it.

## Testing Decisions

Good tests assert external behavior — what comes out given a specific input — without coupling to internal implementation details like regex patterns or iteration order.

**Module tested:** `rule-no-shebang.zsh` via `rule-no-shebang.bats`.

**Test cases:**
- A file with no shebang → no violation (exits 0)
- A file with `#!/usr/bin/env bats` on line 1 → one `noShebang` violation on line 1
- A file with `#!/bin/sh` on line 1 → one `noShebang` violation (any shebang is flagged)
- A file with `# not a shebang` on line 1 → no violation
- A file where `#!` appears on line 2 (not line 1) → no violation

**Prior art:** `rule-no-top-level-var.bats`, `rule-no-inline-function.bats` — both use `run_rule` + `expect_rule_violation` / `expect_clean` helpers from `rules-helper`.

The new test file itself carries no shebang, consistent with the rule it is testing.

## Out of Scope

- Updating `zsh-writer/references/testing.md` — the lint rule enforces the convention; prose duplication is unnecessary.
- Modifying `bats-lint.bats` integration tests — they mock `bats-lint-custom` entirely and do not need updating.
- Removing the shebang exception logic from `rule-no-top-level-var.zsh` — no such logic exists; the rule's regex never matched shebangs.

## Further Notes

`bats-lint-shellcheck` uses `--shell=bash` explicitly and does not rely on shebangs to detect shell type, so removing shebangs has no effect on shellcheck behavior.
