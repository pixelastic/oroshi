## PRD

[PRD — zshlint Custom Rules](./PRD.md)

## What to build

Refactor `zshlint` from a single script into a directory-based Orchestrator that
integrates Custom Rules with shellcheck output into a single JSON array.

The directory structure replaces the current flat script. The entry point script
retains the same name and the same external CLI interface — callers (nvim, AI agents,
developers) notice no change.

The Orchestrator sources all Lib Files at startup via a static ordered list.
For each input file, it calls each Custom Rule function directly (no subshell).
It captures shellcheck JSON output, collects Rule Output lines from all rules,
converts those lines to JSON objects (with `column=1`, `endLine=line`,
`endColumn=1` as defaults for unused fields), and merges everything into a single
JSON array via `jq`. Exit code is 1 if shellcheck or any custom rule found violations.

Shellcheck is captured with `|| true` so `set -e` does not abort the script on
findings. The merged array is the only thing written to stdout.

Integration bats tests verify the full pipeline: a file with a known `shift`
violation produces a merged JSON array containing both shellcheck results and the
`90005` custom rule entry. A clean file produces an empty array. Exit code is
correct in both cases.

## Acceptance criteria

- [ ] `zshlint` is now a directory; entry point script is inside it and remains in PATH via `path.zsh` glob
- [ ] `__rules/` and `__tests__/` subdirectories created (excluded from PATH)
- [ ] `CONTEXT.md` moved into the directory
- [ ] Orchestrator sources Lib Files via static list at startup
- [ ] Orchestrator calls each rule function directly for each input file
- [ ] Rule Output lines are converted to valid JSON objects with correct field defaults
- [ ] Custom JSON merged with shellcheck JSON via `jq`; single array on stdout
- [ ] Exit code 1 when violations found (shellcheck or custom), 0 when clean
- [ ] Integration bats test: file with `shift` → merged array contains `90005` entry
- [ ] Integration bats test: clean file → empty array, exit 0

## Blocked by

- [issue-001 — Rule: no shift](./issue-001-rule-no-shift.md)
