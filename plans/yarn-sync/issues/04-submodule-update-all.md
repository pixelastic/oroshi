## TLDR

New `git-submodule-update-all` wrapping `git submodule update` with path support.

## What to build

Create `git-submodule-update-all` in `git/submodule/`. Accepts an optional path as first positional argument (defaults to current repo). Wraps `git -C "$path" submodule update`.

## Behavioral Tests

**Path argument:**
- accepts a path and runs submodule update in that directory
- defaults to current directory when no argument given

## Acceptance criteria

- [ ] Function exists in `git/submodule/`
- [ ] Accepts optional path as first argument
- [ ] Calls `git -C <path> submodule update`
- [ ] Tests pass in `git/submodule/__tests__/git-submodule-update-all.bats`
