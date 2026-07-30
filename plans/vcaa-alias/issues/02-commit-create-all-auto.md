## TLDR

New `git-commit-create-all-auto` function + `vcaa` alias: stage all, auto-generate message, echo it, commit.

## What to build

1. **New autoload function** `git-commit-create-all-auto` at `tools/term/zsh/config/functions/autoload/git/commit/`:
   - If `$1` exists and doesn't start with `-`, treat it as repo path and shift it out.
   - Call `git-commit-message [repoPath]` and capture stdout.
   - `echo` the message (plain, no decoration).
   - Call `git-commit-create-all [--repo repoPath] "$message" $@` — converts repo to `--repo` flag (since `git-commit-create-all`'s first positional arg is the commit message) and forwards all remaining flags.
   - Uses `setopt local_options err_return` — if message generation fails, the function aborts before committing.

2. **Alias** in `tools/term/zsh/config/aliases/git/commit.zsh`:
   - `vcaa='git-commit-create-all-auto'`

3. **Cleanup**: remove the "vcaa auto-fill the commit message" line from `TODO.md`.

## Behavioral Tests

**Message forwarding:**
- captures git-commit-message output and passes it as commit message to git-commit-create-all

**Argument forwarding:**
- forwards extra flags (e.g. `-n`) to git-commit-create-all

**Repo path handling:**
- passes repo path to git-commit-message as positional arg
- converts repo path to `--repo` flag for git-commit-create-all

**Error handling:**
- aborts without committing when git-commit-message fails

## Acceptance criteria

- [ ] `vcaa` stages all, generates message, prints it, and commits in one shot
- [ ] Extra flags like `-n` are forwarded to the underlying git commit
- [ ] Repo path as first arg targets the correct repository for both message generation and commit
- [ ] If message generation fails, no commit is created
- [ ] TODO.md entry removed
- [ ] Bats tests pass for all behavioral tests above
