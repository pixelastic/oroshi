## TLDR

Update `yarn-install-in-progress` to use new lockfile path and remove false TODO entry.

## What to build

**`yarn-install-in-progress`:**
- Replace the hardcoded `$(git-directory-root)/.git/oroshi_yarn_install_in_progress` with `git-dependencies-in-progress-lockfile node --reply`
- Read lockfile path from `$REPLY` and check its existence
- The prompt indicator continues to work as before

**`TODO.md`:**
- Remove the two lines about `git-worktree-delete` needing to run yarn on main when `package.json` changes — this was a misattribution, fixed by `git-worktree-push` in issue 07

## Behavioral Tests

**`yarn-install-in-progress`:**
- returns true when the node lockfile exists at the new path
- returns false when the node lockfile does not exist

## Acceptance criteria

- [ ] `yarn-install-in-progress` uses `git-dependencies-in-progress-lockfile node --reply`
- [ ] Prompt indicator still shows when yarn is installing
- [ ] False TODO.md entry removed
- [ ] Tests pass
