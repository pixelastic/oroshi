## PRD

[reorg/PRD.md](./PRD.md)

## What to build

Migrate the `infrastructure` domain into `tools/infrastructure/`. The domain has 5 install scripts, no deploy scripts, and 1 config directory. Tools with only an install get a single-file folder.

## Acceptance criteria

- [ ] `tools/infrastructure/` directory created
- [ ] Each tool from `scripts/install/infrastructure/` moved to `tools/infrastructure/{tool}/install`
- [ ] `config/infrastructure/` contents moved to the appropriate `tools/infrastructure/{tool}/config/`
- [ ] No install→deploy wiring needed (no deploy scripts exist)
- [ ] Cross-tool refs in moved files updated to `$OROSHI_ROOT/tools/infrastructure/...`
- [ ] `scripts/install/infrastructure/` and `config/infrastructure/` are empty and removed

## Blocked by

None — can start immediately
