## PRD

[reorg/PRD.md](./PRD.md)

## What to build

Migrate the `docker` domain into `tools/docker/`. The domain has 4 install scripts (`docker`, `docker-compose`, `dry`, `hadolint`), no deploy scripts, and 2 config directories. Tools with only an install get a single-file folder.

## Acceptance criteria

- [ ] `tools/docker/` directory created
- [ ] Each tool from `scripts/install/docker/` moved to `tools/docker/{tool}/install`
- [ ] Each directory from `config/docker/` moved to `tools/docker/{tool}/config/`
- [ ] No install→deploy wiring needed (no deploy scripts exist)
- [ ] Cross-tool refs in moved files updated to `$OROSHI_ROOT/tools/docker/...`
- [ ] `scripts/install/docker/` and `config/docker/` are empty and removed

## Blocked by

None — can start immediately
