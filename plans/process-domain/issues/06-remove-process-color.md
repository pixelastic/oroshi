## TLDR

Remove the `process` color key from the theme; replace its usage with `executable`.

## What to build

1. Remove the `"process"` entry from `tools/term/zsh/config/theming/src/colors.jsonc`
2. In `tools/term/zsh/config/completion/styling.zsh`, replace `$COLORS[process]` with `$COLORS[executable]`
3. Rebuild the dist file by running `colors-build`

## Acceptance criteria

- [ ] `"process"` key no longer exists in `colors.jsonc`
- [ ] `COLORS[process]` no longer referenced anywhere in the codebase
- [ ] `styling.zsh` uses `$COLORS[executable]` instead
- [ ] Dist file rebuilt
