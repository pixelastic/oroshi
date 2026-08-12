## Migrate bats + bats-lint to autoloaded

### Scripts

| Script | NeoVim bin-zsh ? |
|--------|-----------------|
| `bats` | No |
| `bats-lint` | Yes (linter) |

### Complex: __rules/ and sourced files

- `bats-lint-custom.zsh`, `bats-lint-shellcheck.zsh` → `__lib/`
- 8 rule files in `__rules/` → `__rules/`
- Adapt `${0:a:h}` path resolution

### Stay as scripts

- `bats-fixture-script-foo/bar/baz` — test fixtures, must remain on disk

### NeoVim configs to update

- `filetypes/bats.lua` → bats-lint
