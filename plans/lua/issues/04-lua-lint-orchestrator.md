## TLDR

`lua-lint` orchestrator: merge violations from selene and custom rules into a JSON array.

## What to build

The `lua-lint` script calls `lua-lint-selene` and `lua-lint-custom` in sequence, merges their `▮`-separated streams, and serialises the result as a JSON array. Exit 1 if any violations, exit 0 if clean. Mirrors `zshlint`.

BATS tests cover: both sub-tools produce violations (merged JSON contains both); only one sub-tool produces violations (exit 1); neither produces violations (empty array, exit 0).

## Acceptance criteria

- [ ] `lua-lint <file>` outputs a JSON array of violation objects
- [ ] Exit code is 1 when any violation is found, 0 when clean
- [ ] BATS test: violations from both selene and custom rules appear in merged output
- [ ] BATS test: only selene violations — JSON contains only those, exit 1
- [ ] BATS test: only custom violations — JSON contains only those, exit 1
- [ ] BATS test: clean file — empty JSON array `[]`, exit 0
