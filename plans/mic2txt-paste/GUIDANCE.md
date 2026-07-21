## Guidance

- Language: ZSH for scripts, use `zsh-writer` skill
- Testing: `bats <filepath>` — tests in `scripts/bin/audio/__tests__/`
- Linting: `zsh-lint <filepath>` for ZSH, `bats-lint <filepath>` for bats
- Prior art for tests: `scripts/bin/audio/__tests__/mic2txt-cancel.bats`
- Temp folder: `/dev/shm/oroshi/mic2txt/`
- Paste mechanism: `focus-insert` in `scripts/bin/ubuntu/focus-insert`
- Keybinding config: `tools/ubuntu/24.04/keybindings/custom`
- Existing mic2txt keybindings use `XF86Launch5` with modifiers

## Discoveries
