## PRD

[reorg/PRD.md](./PRD.md)

## What to build

Migrate the `keybindings` domain into `tools/keybindings/`. The domain has 4 install scripts, 5 deploy scripts (including deploy-only tools `xkb`, `xmodmap`, `ymdk-build`), and 4 config directories.

## Acceptance criteria

- [ ] `tools/keybindings/` directory created
- [ ] Each tool from `scripts/install/keybindings/` moved to `tools/keybindings/{tool}/install`
- [ ] Each tool from `scripts/deploy/keybindings/` moved to `tools/keybindings/{tool}/deploy`
- [ ] Each directory from `config/keybindings/` moved to `tools/keybindings/{tool}/config/`
- [ ] Deploy scripts reference config via `$(dirname "$0")/config`
- [ ] Install scripts that have a sibling deploy call `$(dirname "$0")/deploy` at the end
- [ ] Cross-tool refs in moved files updated to `$OROSHI_ROOT/tools/keybindings/...`
- [ ] `scripts/install/keybindings/`, `scripts/deploy/keybindings/`, and `config/keybindings/` are empty and removed

## Blocked by

None — can start immediately
