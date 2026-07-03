## Issue 01 — Fix git-file-revert

### git ls-files --error-unmatch logic incorrectly flagged as wrong

```zsh
  if git ls-files --error-unmatch "$file" 2>/dev/null; then
    git rm -f "$file"
    continue
  fi
```

**Problem:** Reviewer claimed `git ls-files --error-unmatch` exits 0 for any tracked file, including files in HEAD, making it the wrong predicate for "staged-new".
**Reason skipped:** Logic is sound. This is an `elif` branch — it only runs when `git cat-file -e HEAD:"$file"` already failed, meaning the file is NOT in HEAD. If `git ls-files --error-unmatch` then exits 0, the file must be in the index but not HEAD, which is exactly staged-new. No change needed.

### No helpers for raw git operations

**Problem:** Standards agent flagged `git cat-file`, `git ls-files`, `git checkout --`, `git rm` as raw porcelain instead of helpers.
**Reason skipped:** No higher-level helpers exist for these specific operations. Using raw git commands is the only option here.
