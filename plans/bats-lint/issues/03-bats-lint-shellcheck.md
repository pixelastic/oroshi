## TLDR

Implement `bats-lint-shellcheck`: ShellCheck wrapper for `.bats` files that outputs JSON violations.

## What to build

A ZSH script (`bats-lint-shellcheck`) that:
1. Runs `shellcheck --shell=bash` on the target `.bats` file
2. Transforms ShellCheck's output to the shared JSON format: `[{ "file", "line", "col", "code", "message" }]`
3. Applies a minimal exclusion list (to be grown over time as false positives are encountered)
4. Outputs the JSON array to stdout

The exclusion list starts minimal — only exclusions that are structurally required for BATS files (e.g. SC2148 for missing shebang, since BATS files use `#!/usr/bin/env bats`). All other false positives are suppressed incrementally as they are discovered.

## Behavioral Tests

**Syntax error detected:**
- A `.bats` fixture with invalid bash syntax → output contains at least one ShellCheck violation

**Clean file:**
- A minimal valid `.bats` fixture → output is `[]`

**JSON format:**
- Each violation object contains `file`, `line`, `col`, `code`, `message`
- `code` matches the ShellCheck rule identifier (e.g. `SC2034`)

## Acceptance criteria

- [ ] `bats-lint-shellcheck <filepath>` outputs a JSON array
- [ ] Detects bash syntax errors in `.bats` files
- [ ] Each violation object contains `file`, `line`, `col`, `code`, `message`
- [ ] `--shell=bash` flag is passed to ShellCheck
- [ ] Exclusion list is minimal and documented in the script
- [ ] Integration tests pass via `rtk bats`
- [ ] `zshlint` passes on all new/modified ZSH files
