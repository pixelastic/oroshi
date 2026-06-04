## TLDR

Refactor `git-file-lint` from a ZSH-only linter into a multi-type dispatcher that handles ZSH and BATS files with grouped output.

## What to build

Refactor the `git-file-lint` autoloaded function:

1. Get all dirty files from git (existing logic)
2. Partition files by type: ZSH files (via `is-zsh`), BATS files (`.bats` extension)
3. For each type that has files, run the corresponding linter (`zshlint` / `bats-lint`) and collect JSON output
4. Display results grouped by type — a header (e.g. `── ZSH ──`, `── BATS ──`) followed by formatted violations
5. Only display a group if it has violations
6. Exit non-zero if any group has violations

The structure must make adding a future file type (e.g. JavaScript) a matter of adding one partition + one linter call.

## Behavioral Tests

**BATS violations surfaced:**
- A dirty `.bats` file containing `run zsh` → output contains a BATS section with the `noRunZsh` violation

**ZSH violations surfaced (regression):**
- A dirty `.zsh` file with a zshlint violation → output contains a ZSH section (existing behavior preserved)

**Mixed dirty files, only BATS violates:**
- Dirty `.zsh` (clean) + dirty `.bats` (with `run zsh`) → only BATS section displayed, no ZSH section

**All clean:**
- No dirty files with violations → no output, exit code 0

## Acceptance criteria

- [ ] Dirty `.bats` files are linted with `bats-lint`
- [ ] Output is grouped by file type with a header per group
- [ ] Groups with no violations are suppressed
- [ ] ZSH linting behaviour is preserved (regression-free)
- [ ] Exit code is non-zero if any group has violations
- [ ] Tests pass via `rtk bats`
- [ ] `zshlint` passes on the modified function file
