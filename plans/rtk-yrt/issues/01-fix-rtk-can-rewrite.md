## TLDR

Replace `rtk-can-rewrite`'s TOML first-word lookup with hardcoded command patterns, and rewrite its tests.

## What to build

`rtk-can-rewrite` currently detects TOML-backed commands by extracting the first word of the command and checking whether a matching `[filters.<firstWord>]` section exists in `filters.toml`. This produces false positives: any `yarn` command would match if a `[filters.yarn]` section exists, even `yarn install`.

Replace this second detection step with a hardcoded array of regex patterns. Each pattern corresponds to a known command family that has a TOML filter (or built-in RTK rewrite). The first step — delegating to `rtk rewrite` for built-ins — stays unchanged.

Patterns to register (from prototype):
- `^bats\b` — all bats invocations
- `^yarn run test(\b| |$)` — yarn run test with any trailing arguments

The function's external contract is unchanged: takes one argument (the full command string), exits 0 if RTK can handle it, exits 1 otherwise, produces no stdout.

Rewrite `rtk-can-rewrite.bats` to match the new behavior. Remove the TOML file copy from `setup()` — the function no longer reads TOML at runtime. Add test cases for the new yarn patterns and the yarn-install negative case.

## Behavioral Tests

**Built-in rewrites (unchanged)**
- exits 0 for `git status`

**TOML-backed commands (now via hardcoded patterns)**
- exits 0 for `bats foo.bats`
- exits 0 for `yarn run test`
- exits 0 for `yarn run test path/to/file.js`
- exits 0 for `yarn run test path/to/file.js -- --reporter verbose`

**Negative cases**
- exits 1 for `yarn install`
- exits 1 for `echo hello`

**No stdout contract**
- produces no stdout for any of the above cases

## Acceptance criteria

- [ ] `rtk-can-rewrite "yarn run test"` exits 0
- [ ] `rtk-can-rewrite "yarn run test foo.js"` exits 0
- [ ] `rtk-can-rewrite "yarn run test foo.js -- --reporter verbose"` exits 0
- [ ] `rtk-can-rewrite "yarn install"` exits 1
- [ ] `rtk-can-rewrite "bats foo.bats"` still exits 0
- [ ] `rtk-can-rewrite "git status"` still exits 0
- [ ] No TOML file is read at runtime
- [ ] All new and existing tests pass (`bats` + `bats-lint`)
