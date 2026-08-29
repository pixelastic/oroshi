# scripts/bin

Binaries in PATH that need a manual entry here rather than being installed by their own install script.

## Why

Some tools expect specific binary names that don't match what's actually installed. A symlink here fixes the mismatch without patching the tool or the install script.

## Entries

- `convert` — ImageMagick v7 dropped `convert` in favor of `magick`. Tools like `studio-pack-generator` still call `convert`. Symlinked to `magick`.
- `eslint_d`, `prettier`, `stylelint`, `solkan` — Node binaries from local `node_modules` exposed in PATH.
- `bin-zsh` — ZSH helper dispatcher.
- `spotify-dbus` — Spotify D-Bus control script.
