## Issue 03 — ZSH rename
### Test files not renamed via git mv
```bash
# old tests deleted, new tests created as new files
```
**Problem:** Spec says "their test files accordingly" implying git mv
**Reason skipped:** Tests were fully rewritten (new behavior, no --type). Delete+create is the correct approach; git mv would produce a misleading diff.

### Test/lint verification not visible to reviewer
**Problem:** Reviewer noted tests and lint weren't verified
**Reason skipped:** Already completed in implementation step before review ran.

## Issue 05 — cleanup
### Icon key name mismatch
```jsonc
"tab-marker-notification": " ",
```
**Problem:** Spec says "Only `tab-notification` remains" but surviving key is `tab-marker-notification`.
**Reason skipped:** Imprecise spec wording. `tab-marker-notification` was introduced in issue 01 and is the correct canonical name per the glossary.

### Process gates already verified
**Problem:** Spec acceptance criteria `python-test`, `python-lint`, `icons-build` not evidenced in diff.
**Reason skipped:** All three were run and passed during the implementation step — these are process gates, not diff-visible changes.
