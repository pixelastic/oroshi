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

### Issue 05 — fzf-docker-images (domain FZF Script)

- **Naming convention**: domain scripts (no keybinding) must be prefixed `fzf-` (e.g. `fzf-docker-images`, `fzf-apt-packages`, `fzf-git-file-history`). Only keybinding scripts keep the `ctrl-` / `ctrl-shift-` prefix. This applies to all future domain scripts.
- The spec says "queries the Docker Hub API" but the legacy source reads from a static cache file (`$OROSHI_ROOT/tools/docker/docker/config/data/src/images-remote.txt`). Keep the cache approach — the API wording is aspirational.
- The spec says "image:tag format" but the cache has plain image names (no tags). `ubuntu` is valid for `docker pull` (defaults to `:latest`).
- `--preview=echo {2..}` works with `--delimiter=   ` to show the description; no separate preview binary needed.

### Issue 06 — ctrl-shift-p (filesystem FZF Script)

- `fs-list-files` uses `fd --color=never` for the absolute-path column to avoid ANSI codes corrupting the `▮` delimiter split. Color can be added to the display column separately later.
- Filesystem scripts use `▮` as column separator (same as all other FZF Scripts) — do NOT use 3-space delimiter from the legacy code.
- `fd` only respects `.gitignore` in git repos (`.git` dir must exist). BATS tests that exercise gitignore behavior must `git init` the tmp dir.
- `helpers/fs.zsh` and `helpers/prompt.zsh` have no `set -e` / `setopt` header; they inherit error handling from the sourcing script — same pattern as `helpers/options.zsh`.
- `${line%%   *}` (3-space prefix strip) correctly extracts the absolute path from two-column output, including paths containing single spaces.

### Issue 04 — apt-packages (domain FZF Script)

- ZSH glob qualifiers `(#qN.mh+20)` do NOT work inside `[[ ]]` — even with `EXTENDED_GLOB`. Assign to an array first: `local staleFiles=(${cacheFile}(#qN.mh+20))`, then test `${#staleFiles[@]} -gt 0`.
- `OROSHI_TMP_FOLDER` is overridden by `zshenv-guest.zsh` after `.zshenv` runs. Tests that need to control it must use `bats_mock_env "OROSHI_TMP_FOLDER" "$tmpFolder"`, NOT `export OROSHI_TMP_FOLDER=...`.
- Legacy `fzf-packages-apt-source-generate` used `declare -A` followed by a shadowing `local` — the correct ZSH pattern for a local associative array is `local -A installedPackages`.
- The `--installed` flag is parsed at the top level and accessed from within `fzf-source()` via ZSH dynamic scoping — no need to pass it as a parameter.

### Issue 16 — ctrl-o pickers (fzf-plans + CTRL_O_PICKERS registry)

- `plan-list-raw` already outputs `absolute_path▮name` format — `fzf-plans --source` is just a thin wrapper; no transformation needed.
- `bats_git_dir` (not raw `git init`) is the correct helper for test repos; it creates `$BATS_GIT_DIR` at `$BATS_TMP_DIR/git` with an initial commit.
- `CTRL_O_PICKERS` is declared `typeset -gA` at file scope in `ctrl-o.zsh` (outside the widget function) — global associative array for ZSH keybinding config files is acceptable.
- Last-word extraction from `$LBUFFER`: `${LBUFFER##* }` strips everything up to the last space, cleanly handles empty buffer (returns full buffer string, which won't match any picker).

### Issue 10 — ctrl-p (files-in-project with simplified-path display)

- Scripts with extra flags beyond `--source/--options/--postprocess` (e.g. `--format`, `--cache-key`, `--query`) cannot use `__lib/init.zsh` — they must hand-roll zparseopts and dispatch, following the `fzf-apt-packages` pattern.
- `zparseopts` with `--flag:=arr` and `--flag=value` syntax puts `=value` in `arr[2]` (including the `=`). Always use space-separated args: `--flag value`.
- `local -A` (not `typeset -gA`) for associative arrays inside widget functions — avoids leaking globals into the shell session.
- `fzf-git-files-stageable-preview` is a standalone preview script, not a full FZF Script — it has no lifecycle functions. Preview helpers are an exception to the four-function GLOSSARY pattern.
- Neovim `onCtrlT` already references deleted `fzf-fs-files-subdir-*` functions — the Ctrl-T handler needs a separate migration (presumably issue 13).

### Issue 08 — ctrl-o (git-root directory search)

- `fd --hidden --type=directory` DOES include `.git` in its output (even though it's a VCS dir). Added `--exclude=.git` to `__lib/fzf-source-directories.zsh` to fix this for all directory-listing scripts.
- The plans context-aware behavior (`ralph` → plans picker) was dropped: the acceptance criteria deleted the plans autoloads, and no replacement FZF Script was in scope. The `ctrl-o.zsh` widget now simply calls `ctrl-o` directly.
- `fzf-git-root` uses `git rev-parse --show-toplevel` (not `--show-superproject-working-tree`). The legacy used `-f` to go to the superproject root in submodules; the new script uses the current repo root only.

### Issue 11 — ctrl-g (regexp-in-project FZF Script)

- For live-reload scripts (`--disabled` + `change:reload`), `fzf-source` reads remaining positional args via `${initArgs[*]}` (joined with space) so multi-word queries from `ctrl-g --source {q}` work correctly.
- Use `--color=never` in `regexp-run` so `fzf-postprocess` can cleanly split on `:` without ANSI codes in the field boundaries.
- Fold-case toggle (F1 bind) was skipped intentionally — the spec mentions it for `regexp.zsh` reuse, but the acceptance criteria omit it; deferred to issue 12 when the helper is actually shared.

### Issue 10b — init.zsh --preview and fzf-main override

- Putting flag dispatch inside `fzf-main` prevents scripts from overriding it. Split into `fzf-main` (default pipeline, overridable) and `fzf-dispatch` (dispatcher for standard flags). All scripts call `fzf-dispatch` at the bottom.
- `fzf-preview` graceful fallback uses `(( $+functions[fzf-preview] ))` — ZSH built-in to check if a function exists without invoking it.
- `initArgs` captures `$@` after zparseopts strips standard flags — these remaining positional args are passed to `fzf-preview` (e.g. `--preview test.txt` → `fzf-preview test.txt`).
- The issue spec says `fzf-git-files-dirty-stageable` but the actual file is `fzf-git-files-stageable` — spec has a naming typo.
