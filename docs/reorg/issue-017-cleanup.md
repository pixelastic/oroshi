## PRD

[reorg/PRD.md](./PRD.md)

## What to build

Delete the three old directory trees once all 16 domain migrations are complete. Also delete `config/__archive/` which is not being migrated. Verify each directory is fully empty before deleting; if anything remains, address it before proceeding.

Directories to delete:
- `scripts/install/`
- `scripts/deploy/`
- `config/`
- `config/__archive/`

Directories to leave untouched:
- `scripts/bin/`
- `scripts/etc/`
- `scripts/yarn/`

## Acceptance criteria

- [ ] `scripts/install/` is empty and removed
- [ ] `scripts/deploy/` is empty and removed
- [ ] `config/` is empty and removed
- [ ] `config/__archive/` is removed (not migrated)
- [ ] `scripts/bin/`, `scripts/etc/`, `scripts/yarn/` are untouched
- [ ] `tools/` contains all 16 migrated domains
- [ ] No references to `~/.oroshi/scripts/install/`, `~/.oroshi/scripts/deploy/`, or `~/.oroshi/config/` remain anywhere in the repo (excluding this docs folder)

## Blocked by

- issue-001 through issue-016
