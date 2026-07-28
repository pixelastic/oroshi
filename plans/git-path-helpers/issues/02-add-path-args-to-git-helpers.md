## TLDR

Add optional path arguments to 5 git helpers so they can operate on repos at arbitrary paths.

## What to build

### `git-directory-is-dirty` — positional `$1`

Add optional `$1` path arg, defaulting to current directory. Use `git -C "$targetPath" status --porcelain --short`.

### `git-file-add` — `--repo` flag

Add `--repo` flag via zparseopts. Use the repo path for the `-C` arg instead of calling `git-directory-root`. Fall back to `git-directory-root` when `--repo` is not provided.

### `git-commit-create-staged` — `--repo` flag

Add `--repo` flag via zparseopts. Use `git -C "$repoPath" commit` instead of bare `git commit`. Fall back to current directory when `--repo` is not provided.

### `git-commit-create` — `--repo` flag

Add `--repo` flag via zparseopts. Thread the repo path to both sub-calls:
- `git-file-add --repo "$repoPath"` (replaces bare `git add --all`)
- `git-commit-create-staged --repo "$repoPath" $@` (replaces bare call)

### `git-branch-push` — `--repo` flag

Replace the custom arg parser with zparseopts. Add `--repo` flag. Thread the repo path to `git-branch-current` and `git-remote-current` (both already accept a path arg), and use `git -C "$repoPath" push`.

## Behavioral Tests

**git-directory-is-dirty:**
- returns 0 when called with path to a dirty repo
- returns 1 when called with path to a clean repo

**git-file-add:**
- stages all files when called with `--repo /path`

**git-commit-create-staged:**
- creates a commit in target repo when called with `--repo /path "message"`

**git-branch-push:**
- pushes current branch of target repo when called with `--repo /path`

## Acceptance criteria

- [ ] `git-directory-is-dirty /path` checks dirtiness at given path
- [ ] `git-file-add --repo /path` stages files in target repo
- [ ] `git-commit-create-staged --repo /path "msg"` commits in target repo
- [ ] `git-commit-create --repo /path "msg"` stages + commits in target repo
- [ ] `git-branch-push --repo /path` pushes target repo's branch
- [ ] All 5 helpers remain backward compatible (no args = current directory)
- [ ] Bats tests pass for all `--repo`/`$1` path scenarios
