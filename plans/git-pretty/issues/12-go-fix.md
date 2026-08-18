## TLDR

ZSH wrapper `go-fix` that runs goimports then gofumpt on Go files.

## What to build

ZSH autoload function at `_languages/go/go-fix`:

- Accepts one or more `.go` file paths
- Runs `goimports -w` (fix imports + format) then `gofumpt -w` (stricter formatting)
- Supports `--filepath` flag for stdin mode (neovim conform.nvim reads from stdin, needs real path for import resolution)
- Exit 0 on success

## Acceptance criteria

- [ ] `go-fix file.go` formats the file in-place
- [ ] `go-fix file1.go file2.go` formats multiple files
- [ ] `cat file.go | go-fix --filepath file.go` reads stdin, writes stdout (for neovim)
- [ ] Imports are organized (goimports)
- [ ] Formatting is strict (gofumpt)
