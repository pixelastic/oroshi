## TLDR

Migrate issue/PR count cache from `.git/oroshi_*_count` to `/tmp/oroshi/` shared temp dir.

## What to build

1. **Identify existing cache pattern** — find how other per-repo caches are stored (e.g. yarn install lockfile in `git-dependencies-in-progress-lockfile`)
2. **Migrate `git-issue-list`** — write `oroshi_issue_count` to shared temp dir instead of `.git/`
3. **Migrate `git-pullrequest-list`** — write `oroshi_pr_count` to shared temp dir instead of `.git/`
4. **Migrate readers** — update `git-issue-count` and `git-pullrequest-count` to read from new location
5. **Ensure temp dir structure** — cache path must be unique per repo (e.g. `/tmp/oroshi/cache/<repo-slug>/issue_count`)

## Acceptance criteria

- [ ] No more writes to `.git/oroshi_*` files
- [ ] Cache stored in `/tmp/oroshi/` following existing per-repo pattern
- [ ] `git-issue-count` and `git-pullrequest-count` read from new location
- [ ] `zsh-lint` passes on all touched files
