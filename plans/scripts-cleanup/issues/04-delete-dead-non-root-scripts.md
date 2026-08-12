## Delete dead non-root scripts

### Scripts to delete

- `scripts/bin/text/text-lines-to-words` — 0 callers
- `scripts/bin/text/text-remove-empty-lines` — 0 callers
- `scripts/bin/text/text-split` — 0 callers
- `scripts/bin/text/text-substring` — 0 callers
- `scripts/bin/text/text-words-to-lines` — 0 callers
- `scripts/bin/ubuntu/screenshot` — 0 callers, no keybinding
- `scripts/bin/audio/translate-api` — replaced by `ai/translate` (Claude-based)
- `scripts/bin/audio/jobsdone` — only caller is alias `♪` (also removed)
- `scripts/bin/git/hooks/pre-commit` — dead template, never linked
- `scripts/bin/git/hooks/pre-commit-bats` — doublon of `scripts/yarn/test-bats`
- `scripts/bin/term/bats/bats-echo` — 0 callers

### Also clean up

- Remove alias `♪` from `zsh/config/aliases/global.zsh` (references deleted `jobsdone` and `say`)
- Remove `tools/keybindings/xbindkeys/` directory (X11, dead on Wayland, keybindings already in Ubuntu 24.04 config)
