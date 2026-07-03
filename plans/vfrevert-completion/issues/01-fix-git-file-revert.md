## TLDR

Fix `git-file-revert` to handle all dirty file states, not just tracked modifications.

## What to build

Rewrite the body of `git-file-revert` to iterate over each argument and dispatch to one of three strategies:

1. **File exists in HEAD** (`git cat-file -e HEAD:"$file"`) → `git checkout -- "$file"` — restores the tracked version, discarding working-tree changes whether staged or not
2. **File in index but not in HEAD** (`git ls-files --error-unmatch`) → `git rm -f "$file"` — removes the staged-new file from the index and disk
3. **Otherwise** (untracked) → `rm "$file"` — deletes the untracked file from disk

Multiple files passed in a single call must all be reverted correctly.

## Behavioral Tests

**Modified tracked file**
- A tracked file modified in the working tree is restored to its HEAD content after revert

**Deleted tracked file**
- A tracked file deleted from the working tree is restored to disk after revert

**Staged-new file**
- A newly created file that has been staged (`git add`) is absent from disk after revert
- After revert, `git status` shows no staged addition

**Untracked file**
- A file that exists on disk but was never staged is absent from disk after revert

**Multiple files**
- When called with several files of mixed states, all are correctly reverted in one invocation

## Acceptance criteria

- [ ] `vfrevert modified-file.txt` restores the file to its HEAD content
- [ ] `vfrevert deleted-file.txt` restores the deleted file to disk
- [ ] `vfrevert staged-new-file.txt` deletes the file and removes it from the index
- [ ] `vfrevert untracked-file.txt` deletes the file from disk
- [ ] `vfrevert file1.txt file2.txt` handles multiple files correctly
- [ ] All bats tests pass
- [ ] `zsh-lint` passes on the modified script
