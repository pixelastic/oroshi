## TLDR

Move `scripts/bin/sysinfo/` scripts into `tools/term/zsh/config/functions/autoload/system/` as autoload functions.

## What to build

Create the `system/` autoload directory and migrate four files from `scripts/bin/sysinfo/`:

- `amd-or-arm` — convert from script (shebang + `set -e`) to autoload function (`setopt local_options err_return`)
- `arm-or-amd` — preserve as symlink pointing to `amd-or-arm`
- `gnome-shell-version` — convert to autoload function
- `ubuntu-version` — convert to autoload function

Delete `scripts/bin/sysinfo/` after migration.

Names stay unchanged — no `sys-` prefix on these.

## Scaffolding Tests

- `amd-or-arm`, `gnome-shell-version`, `ubuntu-version` exist as files in `system/`
- `arm-or-amd` is a symlink to `amd-or-arm`
- `scripts/bin/sysinfo/` no longer exists

## Acceptance criteria

- [ ] `system/` directory exists under `tools/term/zsh/config/functions/autoload/`
- [ ] All four files migrated with autoload conventions (`setopt local_options err_return`, no shebang)
- [ ] `arm-or-amd` symlink preserved and points to `amd-or-arm`
- [ ] `scripts/bin/sysinfo/` deleted
