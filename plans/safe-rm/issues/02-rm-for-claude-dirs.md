## TLDR

Extend `rm-for-claude` to handle recursive directory deletion with batch HEAD check.

## What to build

Extend the existing `rm-for-claude` function to detect recursive flags and validate directories.

On invocation when `-r`, `-R`, or `--recursive` is present and a path argument is a directory:
1. List all files on disk: `find <dir> -type f`
2. List all files in HEAD: `git ls-tree -r --name-only HEAD <dir>`
3. Compare: any file on disk not in HEAD → refuse (the directory contains non-**recoverable** files)
4. All files on disk exist in HEAD → `/bin/rm "$@"`

Edge cases:
- Empty directory with `-r` → safe (no files to check)
- Directory containing only git-ignored files → refuse (git-ignored files are not in HEAD)
- Mix of files and directories in a single command → each validated according to its type

## Behavioral Tests

**Directory with all committed files:**
- deletes directory and exits 0

**Directory with one untracked file:**
- refuses with error message mentioning the untracked file's path
- exits 1
- directory still exists

**Directory with git-ignored file:**
- refuses (git-ignored file not in HEAD)

**Empty directory with -r flag:**
- deletes and exits 0

**Mixed command: committed file + committed directory:**
- deletes all, exits 0

**Mixed command: committed file + directory with untracked file:**
- refuses ALL, exits 1

**-r/-R/--recursive detection:**
- `rm-for-claude -rf dir/` → recursive check triggered
- `rm-for-claude -R dir/` → recursive check triggered
- `rm-for-claude --recursive dir/` → recursive check triggered

## Acceptance criteria

- [ ] `-r`, `-R`, `--recursive` flags detected
- [ ] Directory with all HEAD files → deleted
- [ ] Directory with any non-HEAD file → refused
- [ ] Batch check via `git ls-tree` + `find` (not per-file git calls)
- [ ] No partial deletion with mixed file+dir commands
- [ ] All tests pass
