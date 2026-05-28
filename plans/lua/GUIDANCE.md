## Guidance

- **Language**: all scripts are ZSH. Use `setopt local_options errexit` in autoloaded functions, `set -e` in shebang scripts.
- **Local vars**: use `local var="$(cmd)"` + manual guard. Never split `local` from assignment.
- **Install scripts**: follow the pattern in `scripts/install/_languages/` — curl from GitHub releases to `~/local/bin/`, chmod +x.
- **Violation format**: `file▮code▮level▮line▮message` using Unicode `\u25ae` as separator. Same as `zshlint-custom`.
- **JSON output**: `lua-lint` outputs a JSON array. Parse the ▮-separated stream and convert with jq or a small ZSH loop, same as `zshlint`.
- **BATS tests**: co-located in `__tests__/` directories. Load helper via `bats_load_library rules-helper`. Follow patterns in `scripts/bin/zsh/zshlint/__tests__/`.
- **Spec files**: named `<module>_spec.lua`, co-located in `__tests__/` alongside the Lua source. mini.test syntax: `describe` / `it` / `MiniTest.expect`.
- **minit.lua location**: `config/vim/nvim/config/minit.lua`.
- **selene config location**: `config/_languages/lua/selene/selene.toml` + `vim.yml` (YAML, not TOML — selene 0.31 dropped TOML std format).
- **lua-test-path**: mirrors `bats-test-path` at `scripts/bin/term/bats/bats-test-path`.
- **git-file-lint / git-file-test**: autoloaded functions at `config/term/zsh/functions/autoload/git/file/`. Add a Lua branch alongside the existing ZSH branch.
- **Issue 05 is HITL**: after implementation, a human opens a Lua file in Neovim to verify diagnostics appear correctly before the issue is marked done.
- **Testing**: run `bats <filepath>` for ZSH scripts; no Lua test framework — skip test phase for Lua/NeoVim config changes.
- **Linting**: run `zshlint <filepath>` for ZSH scripts.

## Discoveries

### Issue 01 — selene-install
- selene 0.31 "light" build uses YAML for std library files (`vim.yml`), not TOML (`vim.toml`)
- `std = "lua54+vim"` format is invalid — use `std = "vim"` with a `vim.yml` companion
- Config location: `config/_languages/lua/selene/` (not at Neovim root)

### Issue 02 — lua-lint-selene
- `selene --config` accepts an absolute path and finds the companion `vim.yml` from the same directory
- `start_line` in selene output is 0-indexed — `+1` conversion to display line number is correct
- `local` at script scope is a known ZSH false positive — not a real violation

### Issue 10 — lua-test-path
- `local` and `return` at script top-level are valid in ZSH scripts — reviewer flagging them is a false positive
- Pattern mirrors `bats-test-path` exactly; verified against `scripts/bin/term/bats/bats-test-path` as reference
