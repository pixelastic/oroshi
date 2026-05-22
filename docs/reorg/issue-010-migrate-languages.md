## PRD

[reorg/PRD.md](./PRD.md)

## What to build

Migrate the `_languages` domain into `tools/_languages/`. The underscore prefix is intentional — this domain groups language-specific tooling (linters, formatters, runtimes) and is kept visually distinct from other domains. The domain has 15 install scripts, 6 deploy scripts, and 7 config directories.

## Acceptance criteria

- [ ] `tools/_languages/` directory created
- [ ] Each tool from `scripts/install/_languages/` moved to `tools/_languages/{tool}/install`
- [ ] Each tool from `scripts/deploy/_languages/` moved to `tools/_languages/{tool}/deploy`
- [ ] Each directory from `config/_languages/` moved to `tools/_languages/{tool}/config/`
- [ ] Deploy scripts reference config via `$(dirname "$0")/config`
- [ ] Install scripts that have a sibling deploy call `$(dirname "$0")/deploy` at the end
- [ ] Cross-tool refs in moved files updated to `$OROSHI_ROOT/tools/_languages/...`
- [ ] `scripts/install/_languages/`, `scripts/deploy/_languages/`, and `config/_languages/` are empty and removed

## Blocked by

None — can start immediately
