## PRD

[projects-json-source-of-truth/PRD.md](./PRD.md)

## What to build

Add a pre-commit hook that runs `src/projects-build` and stages the resulting dist files whenever `src/projects.json` appears in the staged diff.

This covers the agent editing path: when Claude edits `src/projects.json` directly without going through NeoVim, the dist files are guaranteed to be regenerated and included in the commit.

The hook should integrate with the existing oroshi hook system (`config/git/git/hooks/hook-proxy`) rather than being a standalone hook file.

## Acceptance criteria

- [ ] Committing with `src/projects.json` staged triggers `src/projects-build` automatically
- [ ] `dist/projects.json` and `dist/projects.zsh` are staged and included in the commit
- [ ] Committing without changes to `src/projects.json` does not run the build
- [ ] If the build fails, the commit is aborted

## Blocked by

- [issue-002-projects-build.md](./issue-002-projects-build.md) — `src/projects-build` must exist before the hook can call it
