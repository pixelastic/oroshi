## PRD

[reorg/PRD.md](./PRD.md)

## What to build

Migrate the `cli` domain into `tools/cli/`. The domain has 13 install scripts, 5 deploy scripts (`bat`, `fd`, `nnn`, `rg`, `tldr`), and 3 config directories (`bat`, `fd`, `rg`). Tools with only an install get a single-file folder.

## Acceptance criteria

- [ ] `tools/cli/` directory created
- [ ] Each tool from `scripts/install/cli/` moved to `tools/cli/{tool}/install`
- [ ] Each tool from `scripts/deploy/cli/` moved to `tools/cli/{tool}/deploy`
- [ ] Each directory from `config/cli/` moved to `tools/cli/{tool}/config/`
- [ ] Deploy scripts reference config via `$(dirname "$0")/config` (no hardcoded paths)
- [ ] Install scripts that have a sibling deploy (`bat`, `fd`, `nnn`, `rg`, `tldr`) call `$(dirname "$0")/deploy` at the end
- [ ] Cross-tool refs in moved files updated to `$OROSHI_ROOT/tools/cli/...` (notably `RIPGREP_CONFIG_PATH` in ZSH configs references `rg`)
- [ ] `scripts/install/cli/`, `scripts/deploy/cli/`, and `config/cli/` are empty and removed

## Blocked by

None — can start immediately
