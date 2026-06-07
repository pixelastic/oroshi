## TLDR

Migrate all prompt and tool-configuration ZSH files from `$COLOR_*` env vars to `$colors[NAME]` array lookups.

## What to build

In all files listed below, replace every `$COLOR_NAME` with `$colors[NAME]`, `$COLOR_NAME_HEXA` with `$colors[NAME:hex]`, `$COLOR_ALIAS_NAME` with `$colors[NAME]`, and `$COLOR_ALIAS_NAME_HEXA` with `$colors[NAME:hex]`. Ensure `colors-load-definitions` is called before first use in each file where it isn't already guaranteed by the call chain.

**Prompt files** (`tools/term/zsh/config/prompt/`):
- `exit-code.zsh`
- `git.zsh`
- `path.zsh`
- `node.zsh`
- `ruby.zsh`
- `yarn.zsh`

**Tool configuration files** (`tools/term/zsh/config/tools/`):
- `fzf.zsh`
- `ls.zsh`
- `exa.zsh`
- `nnn.zsh`
- `zsh.zsh` (zsh-syntax-highlighting)

**Completion** (`tools/term/zsh/config/completion/`):
- `styling.zsh`

## Acceptance criteria

- [ ] No `$COLOR_` references remain in any of the listed files
- [ ] All color accesses use `$colors[NAME]` or `$colors[NAME:hex]`
- [ ] `colors-load-definitions` is called where needed before first color access
- [ ] Prompt renders correctly with colors (manual verification)
- [ ] `fzf`, `ls`, `exa`, `nnn` launch with correct color configuration (manual verification)
- [ ] zsh-syntax-highlighting applies correct colors (manual verification)
