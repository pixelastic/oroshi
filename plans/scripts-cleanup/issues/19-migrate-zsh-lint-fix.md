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

### Enforce Google Shell Style pipe indentation

beautysh already preserves Google style (`cmd \` / `  | cmd2`). Ensure all migrated code uses this style for multi-line pipes. No post-processing needed — just write pipes in Google style.

### NeoVim configs to update

- `filetypes/zsh.lua` → zsh-fix, zsh-lint
