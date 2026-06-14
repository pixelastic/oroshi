## TLDR

Replace `$ZSH_CONFIG_PATH` with `$OROSHI_ROOT/tools/term/zsh/config` in the theming loader and the colors-refresh script.

## What to build

Two prod files still reference the removed `$ZSH_CONFIG_PATH` variable:

- The theming index loader (`tools/term/zsh/config/theming/index.zsh`) sources a filetypes env file using `$ZSH_CONFIG_PATH`. Replace with the equivalent `$OROSHI_ROOT`-based path.
- The `colors-refresh` bin script (`scripts/bin/colors-refresh`) calls `projects-build` via `$ZSH_CONFIG_PATH`. Replace with the equivalent `$OROSHI_ROOT`-based path.

`$OROSHI_ROOT` is exported by `zshenv` before either of these files is loaded, so no load-order changes are needed.

## Acceptance criteria

- [ ] `theming/index.zsh` no longer references `$ZSH_CONFIG_PATH`
- [ ] `scripts/bin/colors-refresh` no longer references `$ZSH_CONFIG_PATH`
- [ ] Both files pass `zsh-lint`
