## TLDR

Rewrite `sidequest` to take a filepath argument instead of a slug, absorbing `sidequest-end`'s logic.

## What to build

Replace the slug-based interface of `sidequest` with a filepath-based one. The script now takes a path to a markdown file as its first argument. The slug is derived from the file's basename without extension. The script validates that the file exists.

The `--prompt` flag is removed — the filepath is always passed as the Claude prompt. The `--focus`/`--no-focus` flags are removed — the Kitty tab always opens without stealing focus.

The existing bats tests are rewritten to match the new interface. Prior art: the existing `sidequest.bats` test file, using `bats_mock` for collaborators and `bats_run_zsh` for script invocation.

## Behavioral Tests

**No argument:**
- exits with error

**File not found:**
- exits with error

**Valid file:**
- calls `git-worktree-create` with the slug derived from the filename
- calls `kitty-tab-create` with `--cwd` set to the worktree path
- calls `kitty-tab-create` with `--cmd` containing the filepath as prompt
- calls `kitty-tab-create` without `--focus`

## Acceptance criteria

- [ ] `sidequest <filepath>` derives slug from filename (basename without extension)
- [ ] Missing argument exits with error
- [ ] Non-existent file exits with error
- [ ] `git-worktree-create` called with derived slug
- [ ] `kitty-tab-create` called with correct `--cwd` and `--cmd @<filepath>`, no `--focus`
- [ ] Old `--prompt` and `--no-focus` flags removed
- [ ] `sidequest.bats` rewritten to match new interface, all tests pass
