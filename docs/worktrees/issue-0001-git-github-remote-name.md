# 0001 — `git-github-remote-name`

## What to build

A new helper in the `git/github/` family that returns the canonical repository
name as a single word.

Primary source: parse the GitHub remote URL of the current remote, extracting
the last path component and stripping the `.git` suffix. Supports both SSH
(`git@github.com:owner/repo.git`) and HTTPS
(`https://github.com/owner/repo.git`) forms.

Fallback (no remote or non-GitHub remote): take the folder name of the Git Repo
Main and strip all leading dots (e.g. `.oroshi` → `oroshi`).

Sits alongside `git-github-remote-owner` and `git-github-remote-project` to
complete the trio — matching Gilmore's `githubRepoName / githubRepoOwner /
githubRepoSlug` convention.

## Acceptance criteria

- [ ] Returns repo name from a SSH GitHub remote URL (`git@github.com:owner/repo.git` → `repo`)
- [ ] Returns repo name from a HTTPS GitHub remote URL (`https://github.com/owner/repo.git` → `repo`)
- [ ] Falls back to folder name (without leading dots) when no remote is configured
- [ ] Strips all leading dots from the fallback folder name (`.myrepo` → `myrepo`)

## Blocked by

None — can start immediately.
