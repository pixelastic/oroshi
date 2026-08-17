## TLDR

Make `git-file-edit` (vfe) prepend dirty GUIDANCE.md and review-log.md from the external plan repo.

## What to build

Modify `tools/term/zsh/config/functions/autoload/git/file/git-file-edit`:

Before building the code file list (existing logic), check for dirty plan artifacts:

1. Resolve plan dir via `plan-directory`. If no plan, skip.
2. Get dirty files in the plan repo: `git -C "$planDir" status --porcelain`.
3. Filter for GUIDANCE.md and review-log.md only.
4. If any are dirty, prepend their absolute paths to the file list (before code files).

These plan artifacts should appear first in the nvim buffer list, so the user reviews learnings before code.

Keep the existing skip logic for `plans/*/state.json` and `plans/*/scaffold/*` — these now only apply if there are leftover local plan files (transition period).

## Behavioral Tests

**git-file-edit.bats** (extend existing):
- Dirty GUIDANCE.md in plan repo → appears in file list
- Dirty review-log.md in plan repo → appears in file list
- Plan artifacts appear before code files in buffer order
- Clean plan repo → no plan artifacts in file list
- No associated plan → works as before (code files only)
- Dirty state.json in plan repo → NOT included (only GUIDANCE.md and review-log.md)

## Acceptance criteria

- [ ] Dirty GUIDANCE.md from external plan repo opens in vfe
- [ ] Dirty review-log.md from external plan repo opens in vfe
- [ ] Plan artifacts appear first in buffer list
- [ ] Clean plan artifacts don't appear
- [ ] state.json and other plan files excluded
- [ ] No plan → no change in behavior
