## Migrate python/ and toml/ to autoloaded

### Scripts

| Script | Domain | NeoVim bin-zsh ? |
|--------|--------|-----------------|
| `python/python-fix` | python/ | Yes (formatter) |
| `python/python-lint` | python/ | Yes (linter) |
| `python/python-test` | python/ | No |
| `toml/toml-lint` | toml/ | No |
| `toml/fly-lint` | toml/ | Yes (linter) |

### NeoVim configs to update with bin-zsh

- `filetypes/python.lua` → python-fix, python-lint
- `filetypes/toml.lua` → fly-lint
