## PRD

[reorg/PRD.md](./PRD.md)

## What to build

Migrate the `windows` domain into `tools/windows/`. The domain has 2 install scripts, no deploy scripts, and 1 config directory.

## Acceptance criteria

- [ ] `tools/windows/` directory created
- [ ] Each tool from `scripts/install/windows/` moved to `tools/windows/{tool}/install`
- [ ] `config/windows/` contents moved to the appropriate `tools/windows/{tool}/config/`
- [ ] No install→deploy wiring needed (no deploy scripts exist)
- [ ] Cross-tool refs in moved files updated to `$OROSHI_ROOT/tools/windows/...`
- [ ] `scripts/install/windows/` and `config/windows/` are empty and removed

## Blocked by

None — can start immediately
