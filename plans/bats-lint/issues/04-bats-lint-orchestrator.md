## TLDR

Implement `bats-lint` orchestrator, `scripts/yarn/lint-bats` wrapper, and wire into lint-staged.

## What to build

Three things in one slice:

**`bats-lint` (orchestrator):** Calls `bats-lint-shellcheck` and `bats-lint-custom` on the target file, merges their JSON arrays, outputs the combined result. Exits non-zero if the array is non-empty.

**`scripts/yarn/lint-bats` (lint-staged wrapper):** Thin wrapper that filters its arguments to `.bats` files only, calls `bats-lint` on each, exits non-zero if any violations are found. Follows the same pattern as `scripts/yarn/lint-zsh`.

**`lintstaged.config.js` update:** Add `'**/*.bats': ['./scripts/yarn/lint-bats']` so staged `.bats` files are linted at pre-commit time.

## Behavioral Tests

**Merges both outputs:**
- A `.bats` fixture with both a ShellCheck error and a `run zsh` call → output contains violations from both `bats-lint-shellcheck` and `bats-lint-custom`

**Clean file:**
- A valid `.bats` fixture with no `run zsh` → output is `[]`, exit code 0

**Non-zero exit on violations:**
- A `.bats` fixture with `run zsh` → exit code is non-zero

## Scaffolding Tests

- `lintstaged.config.js` contains a `**/*.bats` key mapped to `./scripts/yarn/lint-bats`

## Acceptance criteria

- [ ] `bats-lint <filepath>` outputs merged JSON from both sub-linters
- [ ] Exit code is 0 when no violations, non-zero otherwise
- [ ] `scripts/yarn/lint-bats` filters to `.bats` files and delegates to `bats-lint`
- [ ] `lintstaged.config.js` includes `**/*.bats` → `./scripts/yarn/lint-bats`
- [ ] Integration tests pass via `rtk bats`
- [ ] `zshlint` passes on all new/modified ZSH files
