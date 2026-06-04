## TLDR

Implement `bats-lint-custom`: the runner that discovers and executes all `__rules/` functions and outputs merged JSON violations.

## What to build

A ZSH script (`bats-lint-custom`) that:
1. Discovers all rule files in the `__rules/` directory (same discovery mechanism as `zshlint-custom`)
2. Runs each rule function against the target `.bats` file
3. Collects the `▮`-delimited output from each rule
4. Converts violations to the shared JSON format: `[{ "file", "line", "col", "code", "message" }]`
5. Outputs the merged JSON array to stdout

## Behavioral Tests

**Rule violation surfaced:**
- A `.bats` fixture containing `run zsh` → `bats-lint-custom` output contains a JSON object with `code: "noRunZsh"`

**No violations:**
- A `.bats` fixture with no `run zsh` → `bats-lint-custom` outputs an empty JSON array `[]`

**Multiple rules (future-proofing):**
- If two rules both fire on the same file → both violations appear in the output array

**File path in output:**
- The `file` field in each JSON object matches the path passed as argument

## Acceptance criteria

- [ ] `bats-lint-custom <filepath>` outputs a JSON array
- [ ] Each violation object contains `file`, `line`, `col`, `code`, `message`
- [ ] `noRunZsh` violations from issue 01 appear in output
- [ ] Output is `[]` when no rules fire
- [ ] Integration tests pass via `rtk bats`
- [ ] `zshlint` passes on all new/modified ZSH files
