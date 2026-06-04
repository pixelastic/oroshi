## TLDR

Implement the `noRunZsh` custom rule that flags `run zsh` in BATS test files.

## What to build

A standalone ZSH function (one file in `__rules/`) that reads a `.bats` file and outputs a violation for every line containing `run zsh`. The violation code is `noRunZsh` and the message is "Use bats_run_function instead of run zsh".

Lines with a `# bats-lint-disable noRunZsh` inline comment are exempt.

Output format matches the zshlint rule convention: separator-delimited fields (`▮`) per violation: `line▮col▮code▮message`.

## Behavioral Tests

**Detects the pattern:**
- A file containing `run zsh` → one violation with code `noRunZsh` on the correct line

**No false positives:**
- A file with no `run zsh` → no violations
- A file where `run zsh` appears in a string/comment unrelated context → still flagged (simple grep-style rule, no AST)

**Inline disable:**
- A line with `run zsh` followed by `# bats-lint-disable noRunZsh` → no violation

**Multiple occurrences:**
- A file with `run zsh` on three lines → three violations, each on the correct line number

## Acceptance criteria

- [ ] Rule function exists in `__rules/` directory
- [ ] Outputs a `noRunZsh` violation for every `run zsh` occurrence
- [ ] Violation message is "Use bats_run_function instead of run zsh"
- [ ] Lines with `# bats-lint-disable noRunZsh` are skipped
- [ ] Output format matches the `▮`-delimited convention used by zshlint rules
- [ ] Unit tests pass via `rtk bats`
- [ ] `zshlint` passes on all new/modified ZSH files
