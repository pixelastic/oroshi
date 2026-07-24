## Guidance

- Picker script goes in `scripts/bin/fzf/fzf-js-test`
- Tests go in `scripts/bin/fzf/__tests__/fzf-js-test.bats`
- Keybinding mapping in `tools/term/zsh/config/keybindings/ctrl-p.zsh`
- Use `zsh-writer` skill for the picker script
- Prior art for the picker: `scripts/bin/fzf/fzf-bats-test`
- Prior art for the tests: `scripts/bin/fzf/__tests__/fzf-bats-test.bats`
- Prior art for reusing ctrl-p display: `scripts/bin/fzf/ctrl-p` (sources `fzf-source-files.zsh`, `fzf-options-files.zsh`, `fzf-colorize-path.zsh`)
- Lint with `zsh-lint <file>` and `bats-lint <file>`
- Test with `bats <file>`

## Discoveries
