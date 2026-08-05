## TLDR

Clean up audio domain scripts: migrate to autoloaded functions where possible, document, justify stayers.

## What to build

Scripts in scope:
- `audio-duration` — get audio/video duration in seconds
- `mic2txt-autosubmit-mode-toggle` — toggle autosubmit mode
- `mic2txt-language-toggle` — toggle mic2txt language

For each script:
1. Check if called from non-ZSH context (NeoVim, Kitty, Ubuntu keybindings, Argos)
2. If no external caller: migrate to autoloaded function in `tools/term/zsh/config/functions/autoload/audio/`
3. If external caller: keep as script, add `# Script because:` on line 3
4. Ensure doc comment is present (line 1 for function, line 2 for script)
5. Apply rename map from issue 02 if applicable
6. Update any aliases or references

Note: mic2txt-autosubmit-mode-toggle and mic2txt-language-toggle are called by Ubuntu keybindings — they likely must stay as scripts.

## Acceptance criteria

- [ ] Each script is either migrated to autoloaded function or has `# Script because:` justification
- [ ] All scripts/functions have doc comments
- [ ] Aliases and references updated
- [ ] `zsh-lint` passes on all touched files
