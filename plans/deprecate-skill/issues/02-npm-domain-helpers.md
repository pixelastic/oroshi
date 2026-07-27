## TLDR

New `npm-*` domain helpers for checking and deprecating packages on the npm registry.

## What to build

A new domain directory `tools/term/zsh/config/functions/autoload/npm/` with five helpers:

- **`npm-is-published <name>`** — check if a package exists on the npm registry. Thin wrapper around `npm view`, returns exit code 0/1.
- **`npm-is-deprecated <name>`** — check if a published package is deprecated. Parses `npm view <name> --json` output, checks for `deprecated` field. Returns exit code 0 (deprecated) or 1 (not deprecated).
- **`npm-is-logged-in`** — check if user is authenticated to npm. Wraps `npm whoami`, returns exit code 0/1.
- **`npm-login`** — wraps `npm login`. Interactive, for the user to run manually.
- **`npm-deprecate <name> <message>`** — wraps `npm deprecate <name> "<message>"`.

## Behavioral Tests

**`npm-is-deprecated`** (only helper with parsing logic):
- returns 0 when `npm view --json` output contains a `deprecated` field
- returns 1 when `npm view --json` output has no `deprecated` field
- returns 1 when package is not published (npm view fails)

## Acceptance criteria

- [ ] All five helpers created in `tools/term/zsh/config/functions/autoload/npm/`
- [ ] Each helper follows the autoload function pattern (`setopt local_options err_return`)
- [ ] `npm-is-deprecated` tests pass
- [ ] Thin wrappers (`npm-is-published`, `npm-is-logged-in`, `npm-login`, `npm-deprecate`) have no tests (just exit code forwarding)
