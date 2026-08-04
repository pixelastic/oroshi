## TLDR

Add `--repo`, new lockfile path, and no-commit mode to the `git-dependencies-update` chain.

## What to build

Modify three functions:

**`git-dependencies-update`:**
- Add `--repo` via `zparseopts`, pass through to `git-submodule-update-all` and both language-specific updaters
- Replace bare `git submodule update` with `git-submodule-update-all $repoPath`

**`git-dependencies-update-node`:**
- Add `--repo` via `zparseopts`
- Use `git-directory-root $repoPath` instead of `git-directory-root` (no args)
- Use `git-dependencies-in-progress-lockfile node --repo $repoPath` for lockfile path
- Pass `--repo` to `git-file-has-changed`
- When `--repo` is set, prefix `fork` command with `cd $gitRoot &&`
- When no `$originCommit` is given, skip the `git-file-has-changed` check — run unconditionally if beacon file exists

**`git-dependencies-update-ruby`:**
- Same changes as node: `--repo`, new lockfile path via `git-dependencies-in-progress-lockfile ruby`, `--repo` passthrough to `git-file-has-changed`, `cd` prefix for `fork`, no-commit unconditional mode

## Behavioral Tests

**`--repo` propagation:**
- `git-dependencies-update --repo /path` passes the repo to all children

**No origin commit:**
- when no commit is passed and beacon file exists, runs the update unconditionally
- when no commit is passed and beacon file is missing, returns early

**Lockfile path:**
- uses `git-dependencies-in-progress-lockfile` instead of hardcoded `.git/` path

**`fork` command with `--repo`:**
- command string includes `cd <gitRoot> &&` prefix when repo differs from current dir

## Acceptance criteria

- [ ] `--repo` accepted and passed through entire chain
- [ ] `git-submodule-update-all` used instead of bare `git submodule update`
- [ ] Lockfile path from `git-dependencies-in-progress-lockfile`
- [ ] No origin commit = unconditional run
- [ ] `fork` command prefixed with `cd` when `--repo` is set
- [ ] All three functions updated consistently
- [ ] Tests pass
