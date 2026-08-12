## Migrate css/, go/, html/ linters/fixers to autoloaded

### Scripts

| Script | Domain | NeoVim bin-zsh ? |
|--------|--------|-----------------|
| `css/css-lint` | _languages/css/ (already has css-fix there) | Yes |
| `go/gotmpl-fix` | go/ | Yes (formatter) |
| `go/gotmpl-lint` | go/ | Yes (linter) |
| `html/html-fix` | html/ | Yes (formatter) |
| `html/html-lint` | html/ | Yes (linter) |

### NeoVim configs to update with bin-zsh

- `filetypes/css.lua` → css-lint
- `filetypes/gotmpl/init.lua` → gotmpl-lint, gotmpl-fix
- `filetypes/html.lua` → html-lint, html-fix
