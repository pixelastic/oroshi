## TLDR

Neovim filetype config for Go: gopls LSP, go-lint linter, go-fix formatter.

## What to build

New file `tools/vim/nvim/config/lua/oroshi/filetypes/go.lua` following the python.lua pattern:

### LSP

- gopls via mason (add `"gopls"` to mason dependencies and `lsp = { "gopls" }` in filetype config)

### Linter (`configureLinter`)

- Register `oroshi_go_lint` in nvim-lint
- cmd: `bin-zsh`, args: `{ "go-lint", "--json" }`
- Parser converts JSON violations to nvim diagnostics (lnum, col, severity, message, source, code)

### Formatter (`configureFormatter`)

- Register `oroshi_go_fix` in conform.nvim
- cmd: `bin-zsh`, args: `{ "go-fix", "--filepath", "$FILENAME" }`
- stdin mode

### Registration

- Add `go` entry in `plugins/enabled/filetypes.lua` with linters, formatters, lsp, configureLinter, configureFormatter

## Acceptance criteria

- [ ] Opening a `.go` file in neovim starts gopls
- [ ] Lint violations appear as diagnostics
- [ ] Saving a `.go` file auto-formats via go-fix
- [ ] No errors in `:checkhealth`
