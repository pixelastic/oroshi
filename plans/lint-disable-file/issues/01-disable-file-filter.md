## TLDR

Add `disable-file=` scan and filter to `lint-custom-run`, with tests in both zsh-lint and bats-lint test suites.

## What to build

Extend `lint-custom-run` so that when a file's content is loaded into the cache, all lines are also scanned for `# <prefix> disable-file=ruleName1,ruleName2` comments. Matched rule codes are collected into a per-file disabled-rules map. Before the existing line-level disable check, each violation is checked against this map — if the rule code appears in the file's disabled-rules set, the violation is skipped.

The `--disable-prefix` flag already parameterizes the prefix (`zsh-lint` vs `bats-lint`), so no interface changes are needed. Multiple `disable-file=` comments in the same file are additive. The comment may appear anywhere in the file.

Add two tests to `zsh-lint-custom.bats` (using `noGroupedLocals` as the triggered rule) and one test to `bats-lint-custom.bats` (using `noRunZsh`), following the pattern of the existing line-level disable tests in each file.

## Behavioral Tests

**disable-file suppresses all violations in the file (zsh)**
- File has `# zsh-lint disable-file=noGroupedLocals` at top and two `local a b c` violations
- `zsh-lint-custom` exits 0 and outputs `[]`

**disable-file suppresses all violations in the file (bats)**
- File has `# bats-lint disable-file=noRunZsh` at top and a `run zsh -c "..."` violation
- `bats-lint-custom` exits 0 and outputs `[]`

## Acceptance criteria

- [ ] `lint-custom-run` scans file content for `disable-file=` comments when caching a file
- [ ] Violations whose rule code appears in the file's disabled-rules map are filtered out
- [ ] File-level disable works for both `zsh-lint` and `bats-lint` prefixes
- [ ] Multiple `disable-file=` comments in one file are additive
- [ ] Line-level `disable=` continues to work independently
- [ ] `zsh-lint-custom.bats` has two new passing tests for file-level disable
- [ ] `bats-lint-custom.bats` has one new passing test for file-level disable
- [ ] `bats zsh-lint-custom.bats` passes
- [ ] `bats bats-lint-custom.bats` passes
