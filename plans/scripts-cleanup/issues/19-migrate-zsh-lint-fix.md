## Migrate zsh-lint + zsh-fix to autoloaded

### Scripts

| Script | NeoVim bin-zsh ? |
|--------|-----------------|
| `zsh-fix` | Yes (formatter) |
| `zsh-lint` | Yes (linter) |

### Complex: __rules/ and sourced files

- `zsh-lint-custom.zsh`, `zsh-lint-shellcheck.zsh` → `__lib/`
- 24 rule files in `__rules/` → `__rules/`
- Adapt `${0:a:h}` path resolution

### NeoVim configs to update

- `filetypes/zsh.lua` → zsh-fix, zsh-lint
