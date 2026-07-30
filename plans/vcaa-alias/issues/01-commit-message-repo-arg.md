## TLDR

Add optional repo path argument to `git-commit-message` so it can generate messages for arbitrary repositories.

## What to build

Thread an optional repo path through the full `git-commit-message` stack:

1. **ZSH wrapper** (`scripts/bin/git/commit/git-commit-message/git-commit-message`): pass `$1` to the node script as a CLI argument.

2. **JS entry point** (`scripts/bin/git/commit/git-commit-message/git-commit-message.js`): read the CLI arg (e.g. `process.argv[2]`), pass it to `Gilmore(repoPath)` and to all internal helpers that create their own Gilmore instance.

3. **Internal helpers**: `getDiff`, `getDeletedPlanName`, and `getCommitHint` each call `Gilmore()` internally. They need to accept an optional repo path and pass it through to `Gilmore(repoPath)`. When omitted, behavior stays the same (cwd default).

`Gilmore(repoPath)` already supports an optional root path — the work is threading the argument, not changing Gilmore itself.

## Behavioral Tests

**getDiff with repo path:**
- passes repo path to Gilmore when provided
- defaults to no-arg Gilmore when repo path is omitted

**getDeletedPlanName with repo path:**
- passes repo path to Gilmore when provided
- defaults to no-arg Gilmore when repo path is omitted

**getCommitHint with repo path:**
- resolves COMMIT_HINT.md relative to the provided repo path
- defaults to cwd-based resolution when repo path is omitted

## Acceptance criteria

- [ ] `git-commit-message /path/to/repo` generates a message from that repo's staged diff
- [ ] `git-commit-message` (no arg) still works from cwd as before
- [ ] All existing tests still pass
- [ ] New tests cover repo path threading for getDiff, getDeletedPlanName, getCommitHint
