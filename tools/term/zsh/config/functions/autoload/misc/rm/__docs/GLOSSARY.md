# rm

Vocabulary for the `rm` and `rmdir` wrapper functions, which split into CLI (human) and Claude (agent) variants.

## Language

**safe deletion**:
A deletion where the target is inside the current git worktree AND every file is committed in HEAD. A safe deletion is always **recoverable**.
_Avoid_: safe rm, allowed deletion, permitted deletion

**recoverable**:
A file that exists in the HEAD commit. Can be restored via `git checkout` even after deletion from disk. A file that is untracked, git-ignored, or only staged (never committed) is NOT recoverable.
_Avoid_: restorable, reversible, undoable

## Relationships

- A **safe deletion** implies all target files are **recoverable**. The reverse is not true — a single **recoverable** file inside a directory with non-recoverable files does not make the directory deletion safe.
- For files: **recoverable** is checked via `git cat-file -e HEAD:<path>`.
- For directories (`rm -r`): every file on disk under the directory must be **recoverable**. One non-recoverable file makes the entire directory deletion unsafe.
