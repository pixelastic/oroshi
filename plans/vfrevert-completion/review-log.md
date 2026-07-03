## Issue 03 — Ctrl-P picker

### Standards findings are pre-existing (issues 01/02)

**Problem:** git-file-revert placement in autoload vs bin, `complete-git-files-dirty` splits on `:` not `▮`, and count comparison style — all flagged by standards agent.
**Reason skipped:** All pre-existing from issues 01 and 02; out of scope for issue 03.

### Untracked files have no color branch in fzf-source

**Problem:** Spec agent noted untracked files might miss a color branch.
**Reason skipped:** `git-file-list-dirty-raw` maps untracked `??` → `A` status; the `A` branch handles it correctly.

### No --postprocess bats test

**Problem:** Spec agent noted no test for "selecting a file appends its path".
**Reason skipped:** `init.zsh` provides a default `fzf-postprocess()` that strips `▮`; not listed in acceptance criteria.

### Prompt label not updated to "Dirty files"

**Problem:** GUIDANCE specifies prompt label "Dirty files" but implementation uses directory prompt (following prior art exactly).
**Reason skipped:** Acceptance criteria don't mention the prompt label; prior art (`fzf-git-files-dirty-stageable`) also uses directory prompt.

---

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
