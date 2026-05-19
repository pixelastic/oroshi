## PRD

[PRD — zshlint Custom Rules](./PRD.md)

## What to build

Implement the first Custom Rule end-to-end, establishing the full pattern for all
subsequent rules: Lib File, function naming, Rule Output format, bats test file,
and co-located test structure.

The rule detects use of `shift` for argument parsing and flags it as a warning,
suggesting `zparseopts` as the alternative.

**Before writing any code**, run a `grill-with-docs` session with the user to
reach shared understanding of exactly what `shift` usage the rule should detect,
confirm the expected false positive cases (e.g. `shift` as part of a variable name),
and produce the test cases from that session.

The Lib File defines `zshlintRule_noShift(file)`. Given a file path, it scans
for standalone `shift` calls and writes one Rule Output line per violation:
`file▮90005▮warning▮{line}▮Use zparseopts instead of shift for argument parsing`

The bats test file sources the Lib File directly and verifies the function's
behavior against fixture files — no dependency on the full Orchestrator.

## Acceptance criteria

- [ ] `grill-with-docs` session completed, edge cases documented
- [ ] Lib File created in `__rules/` following naming convention
- [ ] Function `zshlintRule_noShift()` outputs a Rule Output line for each `shift` violation
- [ ] Function outputs nothing for files with no `shift` usage
- [ ] Function does not false-positive on `shift` inside variable names or comments
- [ ] bats test file created in `__tests__/`, loads global helper via relative path
- [ ] All bats tests pass

## Blocked by

None — can start immediately.
