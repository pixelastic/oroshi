## PRD

[reorg/PRD.md](./PRD.md)

## What to build

Migrate the `git` domain into `tools/git/`. The domain has 5 install scripts (`act`, `diff-so-fancy`, `gh`, `git`, `git-lfs`), 1 deploy script (`git`), and 1 config directory (`git`). The `git/git` tool illustrates the case where domain and tool share the same name.

## Acceptance criteria

- [ ] `tools/git/` directory created
- [ ] Each tool from `scripts/install/git/` moved to `tools/git/{tool}/install`
- [ ] `scripts/deploy/git/git` moved to `tools/git/git/deploy`
- [ ] `config/git/git/` moved to `tools/git/git/config/`
- [ ] `tools/git/git/deploy` references config via `$(dirname "$0")/config`
- [ ] `tools/git/git/install` calls `$(dirname "$0")/deploy` at the end
- [ ] Cross-tool refs in moved files updated to `$OROSHI_ROOT/tools/git/...`
- [ ] `scripts/install/git/`, `scripts/deploy/git/`, and `config/git/` are empty and removed

## Blocked by

None — can start immediately
