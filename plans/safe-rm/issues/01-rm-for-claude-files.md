## TLDR

Create `rm-for-claude` that validates single-file **safe deletion** before delegating to `/bin/rm`.

## What to build

A ZSH autoloaded function at `tools/term/zsh/config/functions/autoload/misc/rm/rm-for-claude`.

On invocation:
1. Get worktree root via `git rev-parse --show-toplevel`. No repo → exit 1 with error.
2. Parse arguments: detect flags (tokens starting with `-`), collect remaining tokens as paths. Only need to identify flags vs paths — pass all original args through to `/bin/rm` on success.
3. For each path argument:
   - Resolve to absolute path (`${arg:a}`)
   - Check it starts with worktree root — if not, refuse
   - Compute git-relative path and check `git cat-file -e HEAD:<relative-path>` — if not **recoverable**, refuse
4. If all paths pass → `/bin/rm "$@"` (original flags preserved)
5. If any path fails → print error to stderr, exit 1, delete nothing (no partial deletion)

Error format:
```
rm-for-claude: cannot delete '<path>' — not committed in HEAD (unrecoverable)
Use /bin/rm to bypass (requires user approval)
```

Skip recursive directory handling for now (issue 02).

## Behavioral Tests

**Committed file:**
- deletes file and exits 0

**Untracked file:**
- refuses with error message mentioning the path
- exits 1
- file still exists on disk

**Git-ignored file:**
- refuses (not in HEAD)

**Staged but never committed file:**
- refuses (not in HEAD)

**File outside worktree:**
- refuses with error message

**No git repo:**
- refuses with error message

**Multiple files, all committed:**
- deletes all, exits 0

**Multiple files, one uncommitted:**
- refuses ALL (no partial deletion), exits 1
- all files still exist on disk

**Flags passed through:**
- `rm-for-claude -f committed-file` → deletes (flags forwarded to /bin/rm)

## Acceptance criteria

- [ ] Function exists at `tools/term/zsh/config/functions/autoload/misc/rm/rm-for-claude`
- [ ] Committed files deleted via `/bin/rm`
- [ ] Untracked, git-ignored, and staged-only files refused
- [ ] Files outside worktree refused
- [ ] No git repo → refused
- [ ] No partial deletion — all or nothing
- [ ] Error message includes path and bypass hint
- [ ] All tests pass
