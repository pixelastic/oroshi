## Issue 01 — git-status-raw
### File placement in autoload/git/ instead of autoload/git/file/
```zsh
# File: tools/term/zsh/config/functions/autoload/git/git-status-raw
```
**Problem:** Reviewer flagged that the function is placed in `autoload/git/` while similar helpers like `git-file-list-dirty-raw` live in `autoload/git/file/`.
**Reason skipped:** GUIDANCE.md and issue spec explicitly state `git-status-raw` goes in `autoload/git/`, not `autoload/git/file/`. This is a higher-level abstraction over the file-specific `-raw` functions.