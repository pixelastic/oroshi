## TLDR

Create `tools/vim/nvim/config/config/filetypes/bats.lua` so NeoVim displays `bats-lint` violations inline in `.bats` files, mirroring how `zsh.lua` works for ZSH files.

## What to build

A filetype module `filetypes/bats.lua` that:
1. Declares `linters = { "bats-lint" }` for the `bats` filetype
2. Implements `configureLinter(lint)` to register the `bats-lint` command
3. Implements `lintParser` to convert `bats-lint` JSON output to NeoVim diagnostics

## Prior art

- `tools/vim/nvim/config/config/filetypes/zsh.lua` — mirror this exactly
- `bats-lint` (issue 04) outputs a merged JSON array from `bats-lint-custom` and `bats-lint-shellcheck`

## JSON format emitted by `bats-lint`

The orchestrator (issue 04) will standardize the output. The parser must handle at minimum:

```json
[{ "file": "...", "line": N, "col": N, "code": "...", "message": "...", "level": "error|warning|info" }]
```

- `line` and `col` are 1-indexed → subtract 1 for NeoVim (`lnum`, `col`)
- `code` is a string (e.g. `"noRunZsh"`, `"SC2086"`)
- `level` maps to NeoVim severity via `severityStringToInt` (same helper as zsh.lua)

## Acceptance criteria

- [ ] `tools/vim/nvim/config/config/filetypes/bats.lua` exists
- [ ] `linters = { "bats-lint" }` declared
- [ ] `configureLinter` registers `bats-lint` with `stdin = false`, `ignore_exitcode = true`
- [ ] `lintParser` converts JSON to diagnostics with correct `lnum`, `col`, `severity`, `message`, `code`
- [ ] Violations from both `bats-lint-custom` and `bats-lint-shellcheck` appear inline in NeoVim
- [ ] No Lua test needed (per project convention — no Lua test framework)
