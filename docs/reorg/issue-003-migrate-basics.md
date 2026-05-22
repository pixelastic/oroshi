## PRD

[reorg/PRD.md](./PRD.md)

## What to build

Migrate the `basics` domain into `tools/basics/`. The domain has 10 install scripts, 5 deploy scripts, and 7 config directories. Several tools are deploy-only (pre-configured OS components: `apt-get`, `editorconfig`, `hosts`, `ssh`, `wget`) and get a folder with just `deploy` and/or `config/`.

## Acceptance criteria

- [ ] `tools/basics/` directory created
- [ ] Each tool from `scripts/install/basics/` moved to `tools/basics/{tool}/install`
- [ ] Each tool from `scripts/deploy/basics/` moved to `tools/basics/{tool}/deploy`
- [ ] Each directory from `config/basics/` moved to `tools/basics/{tool}/config/`
- [ ] Deploy scripts reference config via `$(dirname "$0")/config` (no hardcoded paths)
- [ ] Install scripts that have a sibling deploy call `$(dirname "$0")/deploy` at the end
- [ ] Cross-tool refs in moved files updated to `$OROSHI_ROOT/tools/...`
- [ ] `scripts/install/basics/`, `scripts/deploy/basics/`, and `config/basics/` are empty and removed

## Blocked by

None — can start immediately
