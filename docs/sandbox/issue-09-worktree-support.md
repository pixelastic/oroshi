## What to build

Detect when the workspace is a git worktree and automatically mount the parent
`.git` directory so that git works correctly inside the container.

A workspace is a worktree when its `.git` entry is a regular file (not a
directory). That file contains a `gitdir:` line pointing to the parent repo's
`.git/worktrees/<name>`. The parent `.git/` directory is extracted by stripping
the `/worktrees/<name>` suffix.

The parent `.git/` is mounted read-only at its **original absolute host path**
inside the container, so the `gitdir:` pointer resolves without any rewriting.

If `.git` is a directory (normal repo), no extra mount is added.

The worktree detection logic is a pure function (input: workspace path, output:
parent git path or empty string) and must be tested in isolation without Docker.

## Acceptance criteria

- [ ] Bats test written and failing before implementation begins (pure detection logic, no Docker)
- [ ] Given a workspace where `.git` is a file containing `gitdir: /path/to/repo/.git/worktrees/branch`, the parent git path `/path/to/repo/.git` is extracted correctly
- [ ] Given a workspace where `.git` is a directory, no parent git mount is added
- [ ] `git status` works inside the sandbox when the workspace is a worktree
- [ ] `git log` and `git commit` work inside the sandbox when the workspace is a worktree
- [ ] The parent `.git/` mount is read-only
- [ ] Bats test passes

## Blocked by

- issue-02-basic-sandbox
