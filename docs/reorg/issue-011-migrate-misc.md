## PRD

[reorg/PRD.md](./PRD.md)

## What to build

Migrate the `misc` domain into `tools/misc/`. The domain has 5 install scripts, 1 deploy script, and 2 config directories.

## Acceptance criteria

- [ ] `tools/misc/` directory created
- [ ] Each tool from `scripts/install/misc/` moved to `tools/misc/{tool}/install`
- [ ] Each tool from `scripts/deploy/misc/` moved to `tools/misc/{tool}/deploy`
- [ ] Each directory from `config/misc/` moved to `tools/misc/{tool}/config/`
- [ ] Deploy script references config via `$(dirname "$0")/config`
- [ ] Install script that has a sibling deploy calls `$(dirname "$0")/deploy` at the end
- [ ] Cross-tool refs in moved files updated to `$OROSHI_ROOT/tools/misc/...`
- [ ] `scripts/install/misc/`, `scripts/deploy/misc/`, and `config/misc/` are empty and removed

## Blocked by

None — can start immediately
