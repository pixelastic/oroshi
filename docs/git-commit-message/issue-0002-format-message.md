## PRD

docs/git-commit-message/PRD.md

## What to build

Implement and test the `formatMessage` function in isolation. It takes a raw
string from the API and returns a formatted commit message where:

- The subject line (first line) is kept intact, never wrapped regardless of length
- A blank line separates subject from body (preserved as-is)
- Every body line is wrapped at 72 characters on word boundaries

The function is exported as a named export so it can be unit-tested
independently of git and the API.

This is the first vitest test file in the repo — set up vitest if not already
configured.

## Acceptance criteria

- [ ] `formatMessage` is a named export from the `git-commit-message` script
- [ ] Subject line longer than 72 chars is returned on a single line, unmodified
- [ ] Body lines exceeding 72 chars are wrapped at word boundaries
- [ ] Body lines already under 72 chars are not modified
- [ ] Blank line between subject and body is preserved
- [ ] All `formatMessage` unit tests pass

## Blocked by

- issue-0001-eslint-shebang.md
