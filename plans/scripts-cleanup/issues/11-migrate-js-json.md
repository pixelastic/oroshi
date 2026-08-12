## Migrate js/ and json/ to autoloaded

### js/

| Script | NeoVim bin-zsh ? |
|--------|-----------------|
| `js-fix` | Yes (formatter) |
| `js-lint` | Yes (linter) |
| `eslint-fix` | Indirect (via js-fix) |
| `eslint-lint` | Indirect (via js-lint) |
| `prettier-fix` | Indirect (via html-fix) |

### json/

| Script | NeoVim bin-zsh ? |
|--------|-----------------|
| `json-fix` | Yes (formatter) |
| `json-lint` | Yes (linter) |
| `json-head` | No |
| `json-random` | No |
| `jsonc-remove-key` | No (ZSH wrapper + __lib/ JS — adapt paths) |

### NeoVim configs to update

- `filetypes/javascript.lua` → js-fix, js-lint
- `filetypes/json.lua` → json-fix, json-lint
