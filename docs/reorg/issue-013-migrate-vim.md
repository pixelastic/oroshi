## PRD

[reorg/PRD.md](./PRD.md)

## What to build

Migrate the `vim` domain into `tools/vim/`. The domain has 2 install scripts (`nvim`, `vint`), 2 deploy scripts, and 2 config directories — a clean 1:1:1 mapping.

## Acceptance criteria

- [ ] `tools/vim/` directory created
- [ ] `scripts/install/vim/nvim` moved to `tools/vim/nvim/install`
- [ ] `scripts/install/vim/vint` moved to `tools/vim/vint/install`
- [ ] `scripts/deploy/vim/nvim` moved to `tools/vim/nvim/deploy`
- [ ] `scripts/deploy/vim/vint` moved to `tools/vim/vint/deploy`
- [ ] `config/vim/nvim/` moved to `tools/vim/nvim/config/`
- [ ] `config/vim/vint/` moved to `tools/vim/vint/config/`
- [ ] Deploy scripts reference config via `$(dirname "$0")/config`
- [ ] Both install scripts call `$(dirname "$0")/deploy` at the end
- [ ] Cross-tool refs in moved files updated to `$OROSHI_ROOT/tools/vim/...`
- [ ] `scripts/install/vim/`, `scripts/deploy/vim/`, and `config/vim/` are empty and removed

## Blocked by

None — can start immediately
