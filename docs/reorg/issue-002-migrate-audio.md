## PRD

[reorg/PRD.md](./PRD.md)

## What to build

Migrate the `audio` domain into `tools/audio/`. The domain has 10 install scripts, no deploy scripts, and 1 config directory. An `index` file exists and must be converted to `install-all`. No install→deploy wiring needed (no deploy scripts).

## Acceptance criteria

- [ ] `tools/audio/` directory created
- [ ] Each tool from `scripts/install/audio/` moved to `tools/audio/{tool}/install`
- [ ] `config/audio/` contents moved to the appropriate `tools/audio/{tool}/config/`
- [ ] `scripts/install/audio/index` converted to `tools/audio/install-all` with internal calls updated to `"$(dirname "$0")/{tool}/install"`
- [ ] No hardcoded `~/.oroshi/` paths remain in moved files; cross-tool refs use `$OROSHI_ROOT/tools/...`
- [ ] `scripts/install/audio/` and `config/audio/` are empty and removed

## Blocked by

None — can start immediately
