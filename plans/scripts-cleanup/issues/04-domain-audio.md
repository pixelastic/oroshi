## TLDR

Clean up audio domain scripts: migrate to autoloaded functions where possible, document, justify stayers.

## What to build

Scripts in scope:
- `audio-duration` — get audio/video duration in seconds
- `mic2txt-autosubmit-mode-toggle` — toggle autosubmit mode
- `mic2txt-language-toggle` — toggle mic2txt language

For each script:
1. Migrate to autoloaded function
2. Apply rename map from issue 02 if applicable
3. If called from external context (NeoVim, Kitty, Ubuntu keybindings, Argos), update call site to `bin-zsh <function>`
4. Update any aliases or references

Note: mic2txt-autosubmit-mode-toggle and mic2txt-language-toggle are called by Ubuntu keybindings — call sites become `bin-zsh mic2txt-autosubmit-mode-toggle` etc.

## Acceptance criteria

- [ ] All scripts migrated to autoloaded functions
- [ ] External call sites updated to use `bin-zsh`
- [ ] Aliases and references updated
- [ ] `zsh-lint` passes on all touched files
