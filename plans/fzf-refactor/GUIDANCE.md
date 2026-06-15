## Guidance

### What this plan does

Replaces the Legacy FZF system (119 autoloaded ZSH functions in `tools/term/zsh/config/functions/autoload/fzf/`)
with FZF Scripts (`scripts/bin/fzf/`) using a strangler fig migration. New scripts are merged to
main one at a time alongside the legacy system; legacy autoloads are deleted as each script lands.

### Vocabulary

All terms are defined in `scripts/bin/fzf/GLOSSARY.md`. Key terms:
- **FZF Script**: executable `#!/bin/zsh` in `scripts/bin/fzf/`
- **Lifecycle Functions**: `fzf-source`, `fzf-options`, `fzf-postprocess`, `fzf-main`
- **FZF Helpers**: `.zsh` files in `scripts/bin/fzf/helpers/` — sourced, not executed
- **Neovim API**: `--source` / `--options` / `--postprocess` flag interface
- **Legacy FZF**: the autoloaded functions being replaced

### FZF Script structure (every script follows this exactly)

```zsh
#!/bin/zsh
source "$(dirname $0)/helpers/options.zsh"
# source other helpers as needed

fzf-source() { ... }      # generates candidates, one per line on stdout
fzf-options() { ... }     # outputs FZF CLI flags, one per line on stdout
fzf-postprocess() { ... } # reads raw selection from stdin, outputs clean result
fzf-main() {
  fzf-source | fzf $(fzf-options) | fzf-postprocess
}

case "$1" in
  --source)      fzf-source ;;
  --options)     fzf-options ;;
  --postprocess) fzf-postprocess ;;
  *)             fzf-main ;;
esac
```

### Neovim API usage (disk.lua pattern)

```lua
source  = vim.fn.systemlist("ctrl-p --source"),
options = vim.fn.systemlist("ctrl-p --options"),
sinklist = function(lines)
  local result = vim.fn.system("echo " .. vim.fn.shellescape(lines[1]) .. " | ctrl-p --postprocess")
  vim.cmd("tab drop " .. result)
end
```

### Testing commands

- ZSH: `rtk bats <filepath>`
- JS: `yarn run test <filepath>`
- Lint ZSH: `zsh-lint <filepath>`

### Test locations

BATS tests live in `__tests__/` adjacent to the script being tested.
Example: `scripts/bin/fzf/__tests__/ctrl-r.bats`

### What to test

Test `fzf-source` (call with `--source`, verify stdout) and `fzf-postprocess` (pipe input,
verify stdout). Do NOT test `fzf-main` (requires interactive terminal) or `fzf-options`
(static flags, no meaningful assertions).

### Prior art for BATS tests

- `tools/term/zsh/config/functions/autoload/fzf/helpers/__tests__/` — existing FZF BATS tests
- `tools/term/zsh/config/functions/autoload/fzf/claude/sessions/` — source tests pattern

### Reference implementations

Two worktrees contain completed reference implementations (never merged, for backporting only):
- `oroshi--skills-reference`: simplified-path display for `ctrl-p` (issues 10)
- `oroshi--completion-ctrlp`: CTRL_P_PICKERS registry and compdef system (issue 10)

### Neovim Lua changes

No Lua test framework exists. Skip the test phase for Lua-only changes (issues 13).
See project memory: `feedback_no_lua_tests.md`.

### ZSH conventions

- Use `[[ $isXxx == "1" ]]` not `(( isXxx ))` for flag tests
- Use `if/then/fi` for 2+ instructions; `&&` only for single-action one-liners
- Use `local var="$(cmd)"` + manual guard for local assignments
- Fix pre-existing zsh-lint violations in any file you touch

## Discoveries

_Append findings here after each issue. Format: `### Issue XX — short title` + bullet points._

### Issue 02 — ctrl-r (first FZF Script)

- `zsh-lint` flags `case "$1"` as `noManualArgParsing` — requires `zparseopts` + if/elif dispatch instead. This changes the pattern from what the issue spec prescribed; subsequent scripts must follow the zparseopts pattern, not `case "$1"`.
- `${0:h}` is the correct ZSH idiom for `dirname $0` inside a shebang script (fixes `noExternalBasename`).
- `fzf-options` output must be split into an array with `${(f)"$(fzf-options)"}` before passing to `fzf`, to avoid SC2046 word-splitting warning.
- `fzf-postprocess` uses `${(f)input}` loop + `${line#*: [0-9]*:[0-9]*;}` glob-strip instead of `while read | sed` (fixes `noWhileRead` + SC2001).
- BATS: use `bats_run_zsh "script-name --flag"` — call the binary by name, no `CURRENT` path variable needed. Scripts are on PATH via `zshenv-guest.zsh`.

### Issue 04 — apt-packages (domain FZF Script)

- ZSH glob qualifiers `(#qN.mh+20)` do NOT work inside `[[ ]]` — even with `EXTENDED_GLOB`. Assign to an array first: `local staleFiles=(${cacheFile}(#qN.mh+20))`, then test `${#staleFiles[@]} -gt 0`.
- `OROSHI_TMP_FOLDER` is overridden by `zshenv-guest.zsh` after `.zshenv` runs. Tests that need to control it must use `bats_mock_env "OROSHI_TMP_FOLDER" "$tmpFolder"`, NOT `export OROSHI_TMP_FOLDER=...`.
- Legacy `fzf-packages-apt-source-generate` used `declare -A` followed by a shadowing `local` — the correct ZSH pattern for a local associative array is `local -A installedPackages`.
- The `--installed` flag is parsed at the top level and accessed from within `fzf-source()` via ZSH dynamic scoping — no need to pass it as a parameter.
