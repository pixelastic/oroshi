## PRD

docs/git-commit-message/PRD.md

## What to build

Add error handling for the two known failure modes: nothing staged, and missing
API key. Both must exit with code 1 and print a clear message to stderr.

## Acceptance criteria

- [ ] Exits 1 with an error message to stderr when no files are staged (after `yarn.lock` exclusion)
- [ ] Exits 1 with an error message naming `ANTHROPIC_API_KEY` explicitly when the env var is not set
- [ ] No API call is made in either error case
- [ ] Happy path behavior from issue-0003 is unaffected

## Blocked by

- issue-0003-script-core.md
