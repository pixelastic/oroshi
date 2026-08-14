## TLDR

Create `rmdir-for-claude` that validates worktree membership before delegating to `/bin/rmdir`.

## What to build

A ZSH autoloaded function at `tools/term/zsh/config/functions/autoload/misc/rm/rmdir-for-claude`.

On invocation:
1. Get worktree root via `git rev-parse --show-toplevel`. No repo → exit 1.
2. For each argument: resolve to absolute path, check it starts with worktree root.
3. All inside worktree → `/bin/rmdir "$@"`
4. Any outside → error + exit 1

No HEAD check — `rmdir` only works on empty directories, so there are no files to lose.

Error format:
```
rmdir-for-claude: cannot delete '<path>' — outside git worktree
Use /bin/rmdir to bypass (requires user approval)
```

## Behavioral Tests

**Empty dir inside worktree:**
- deletes and exits 0

**Dir outside worktree:**
- refuses with error message
- exits 1

**No git repo:**
- refuses with error message

**Multiple dirs, one outside worktree:**
- refuses ALL, exits 1

## Acceptance criteria

- [ ] Function exists at `tools/term/zsh/config/functions/autoload/misc/rm/rmdir-for-claude`
- [ ] Dirs inside worktree → deleted via `/bin/rmdir`
- [ ] Dirs outside worktree → refused
- [ ] No git repo → refused
- [ ] All tests pass
