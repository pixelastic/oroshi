## PRD

[reorg/PRD.md](./PRD.md)

## What to build

Migrate the `ubuntu` domain into `tools/ubuntu/`. Ubuntu uses a version as an intermediate level, with each OS feature as its own tool underneath. No install scripts (Ubuntu is pre-installed). Each sub-feature under a version (`autostart`, `keybindings`, `topbar`, `tweaks`, etc.) becomes its own tool with its own `deploy` and `config/`.

Structure:
```
tools/ubuntu/
  22.04/
    {feature}/
      deploy
      config/
  24.04/
    {feature}/
      deploy
      config/
```

## Acceptance criteria

- [ ] `tools/ubuntu/22.04/` and `tools/ubuntu/24.04/` directories created
- [ ] Each sub-feature from `scripts/deploy/ubuntu/22.04/` moved to `tools/ubuntu/22.04/{feature}/deploy`
- [ ] Each sub-feature from `scripts/deploy/ubuntu/24.04/` moved to `tools/ubuntu/24.04/{feature}/deploy`
- [ ] `config/ubuntu/22.04/` contents distributed into `tools/ubuntu/22.04/{feature}/config/`
- [ ] `config/ubuntu/24.04/` contents distributed into `tools/ubuntu/24.04/{feature}/config/`
- [ ] Deploy scripts reference config via `$(dirname "$0")/config`
- [ ] Cross-tool refs in moved files updated to `$OROSHI_ROOT/tools/ubuntu/...`
- [ ] `scripts/install/ubuntu/`, `scripts/deploy/ubuntu/`, and `config/ubuntu/` are empty and removed

## Blocked by

None — can start immediately
