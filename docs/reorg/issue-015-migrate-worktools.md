## PRD

[reorg/PRD.md](./PRD.md)

## What to build

Migrate the `worktools` domain into `tools/worktools/`. The domain has 14 install scripts, 1 deploy script, and 2 config directories.

## Acceptance criteria

- [ ] `tools/worktools/` directory created
- [ ] Each tool from `scripts/install/worktools/` moved to `tools/worktools/{tool}/install`
- [ ] Each tool from `scripts/deploy/worktools/` moved to `tools/worktools/{tool}/deploy`
- [ ] Each directory from `config/worktools/` moved to `tools/worktools/{tool}/config/`
- [ ] Deploy script references config via `$(dirname "$0")/config`
- [ ] Install script that has a sibling deploy calls `$(dirname "$0")/deploy` at the end
- [ ] Cross-tool refs in moved files updated to `$OROSHI_ROOT/tools/worktools/...`
- [ ] `scripts/install/worktools/`, `scripts/deploy/worktools/`, and `config/worktools/` are empty and removed

## Blocked by

None — can start immediately
