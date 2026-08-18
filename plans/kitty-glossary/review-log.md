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
