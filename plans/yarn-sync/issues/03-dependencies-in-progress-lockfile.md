## TLDR

New `git-dependencies-in-progress-lockfile` returning the semaphore lockfile path for dependency updates.

## What to build

Create `git-dependencies-in-progress-lockfile` in `git/dependencies/`. Required first argument is the language (`node`, `ruby`). Accepts `--repo` for targeting a different repository and `--reply` to write to `$REPLY` instead of echoing.

Returns: `$OROSHI_TMP_FOLDER/git-dependencies-update/<context-slug>--<language>.lock`

Creates the `$OROSHI_TMP_FOLDER/git-dependencies-update/` directory if it doesn't exist.

When `--repo` is passed, `context-slug` receives that path so the lockfile is named after the target repo's context, not the caller's.

## Behavioral Tests

**Basic path generation:**
- returns path under `$OROSHI_TMP_FOLDER/git-dependencies-update/`
- filename ends with `--node.lock` for language `node`
- filename ends with `--ruby.lock` for language `ruby`

**`--repo` flag:**
- uses the target repo's context slug, not the current directory's

**`--reply` flag:**
- writes to `$REPLY` instead of stdout
- no output on stdout when `--reply` is set

**Directory creation:**
- creates the parent directory if it doesn't exist

## Acceptance criteria

- [ ] Function exists in `git/dependencies/`
- [ ] First argument (language) is required
- [ ] `--repo` targets a specific repository
- [ ] `--reply` writes to `$REPLY`
- [ ] Parent directory is created if missing
- [ ] Tests pass in `git/dependencies/__tests__/git-dependencies-in-progress-lockfile.bats`
