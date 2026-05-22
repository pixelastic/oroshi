## PRD

[reorg/PRD.md](./PRD.md)

## What to build

Migrate the `image` domain into `tools/image/`. The domain has 9 install scripts, 2 deploy scripts (`flameshot`, `imagemagick`), 2 config directories, and an `index` file to convert to `install-all`. Note: the domain was previously aliased as `img` in some places — this migration normalizes all references to `image`.

## Acceptance criteria

- [ ] `tools/image/` directory created
- [ ] Each tool from `scripts/install/image/` (excluding `index`) moved to `tools/image/{tool}/install`
- [ ] `scripts/deploy/image/flameshot` moved to `tools/image/flameshot/deploy`
- [ ] `scripts/deploy/image/imagemagick` moved to `tools/image/imagemagick/deploy`
- [ ] `config/image/flameshot/` moved to `tools/image/flameshot/config/`
- [ ] `config/image/imagemagick/` moved to `tools/image/imagemagick/config/`
- [ ] Deploy scripts reference config via `$(dirname "$0")/config`
- [ ] `tools/image/flameshot/install` and `tools/image/imagemagick/install` call `$(dirname "$0")/deploy` at the end
- [ ] `scripts/install/image/index` converted to `tools/image/install-all` with internal calls updated to `"$(dirname "$0")/{tool}/install"`
- [ ] All references to `img` domain renamed to `image` in moved files
- [ ] `scripts/install/image/`, `scripts/deploy/image/`, and `config/image/` are empty and removed

## Blocked by

None — can start immediately
