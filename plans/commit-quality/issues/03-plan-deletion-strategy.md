## TLDR

Add a deterministic plan-deletion strategy to git-commit-message that returns a hardcoded `plan(<slug>): delete completed artifacts` message when both plan sentinel files are staged as deleted, bypassing the API entirely.

## What to build

### New detection module

A new module that inspects the list of staged files (with their git status) and determines whether the staged changes represent a plan deletion. Detection logic:

- Get all staged files and their statuses from git
- Check if `plans/<slug>/PRD.md` AND `plans/<slug>/state.json` are both present with status `D` (deleted) for the same slug
- Both sentinels must be deleted for the same slug — one alone is not sufficient
- If detected: return `plan(<slug>): delete completed artifacts`
- If not detected: return null

The module takes the staged file list as input (injected, not fetched internally) so it can be tested without a real git repo.

### git-commit-message.js — wire the new strategy

Before selecting between commitWithHint and commitWithoutHint, check for plan deletion. If the detection module returns a non-null message, print it and exit — no API call made. The check order is:

1. Plan-deletion detection → if match, return hardcoded message
2. Existing logic: commitWithHint if COMMIT_HINT.md exists, else commitWithoutHint

### Tests

First vitest test file in the oroshi repo. Located in `__tests__/` next to the module. Tests cover only the detection module's external behavior — input is a list of `{ path, status }` objects, output is a commit message string or null.

## Behavioral Tests

**Both sentinels deleted — same slug**
- Given PRD.md and state.json both deleted under plans/bats-shebang/, returns `plan(bats-shebang): delete completed artifacts`

**Mixed commit — sentinels deleted plus other staged files**
- Given PRD.md and state.json deleted plus an unrelated modified file, still returns the hardcoded plan message

**Only one sentinel deleted**
- Given only PRD.md deleted (state.json not staged), returns null

**Sentinels deleted from different slugs**
- Given PRD.md from plans/foo/ and state.json from plans/bar/ deleted, returns null (no single slug has both)

**No deletions**
- Given only modified or added files, returns null

**Empty staged list**
- Returns null

## Scaffolding Tests

None.

## Acceptance criteria

- [ ] Detection module is a pure function: takes staged file list, returns string or null
- [ ] Both sentinels must be deleted for the same slug to trigger
- [ ] Mixed commits (sentinels + other files) still trigger the hardcoded message
- [ ] One sentinel deleted alone does not trigger
- [ ] Sentinels from different slugs do not trigger
- [ ] git-commit-message.js checks for plan deletion before commitWithHint/commitWithoutHint
- [ ] When triggered, no API call is made
- [ ] All behavioral tests pass
- [ ] Linter clean on all modified files
