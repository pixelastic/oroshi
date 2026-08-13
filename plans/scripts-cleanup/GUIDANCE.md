# Guidance

## Discoveries

### Issue 03 — Migrate root-level scripts to autoloaded functions
- Many bin scripts already had identical copies in autoload (apt-packages-cache-generate, better-cat, better-ls, better-ydotool, colors, colors-reload, extract) — just needed header conversion and bin deletion
- gif2png already existed as a proper autoloaded function in img/gif/ — bin version was a stale duplicate
- beautysh (used by zsh-lint formatter) cannot parse zsh glob patterns like `*.r([0-9][0-9]))` or `(N)` qualifiers — use `# shellcheck disable` comments to suppress false positives
- `urls` migration deferred per spec (TBD name and domain)

### Issue 11 — Migrate js/ and json/
- `${0:A:h}` doesn't work in autoloaded functions (`$0` is the function name, not a file path) — use `${functions_source[$0]:A:h}` instead, which resolves the source file path of the current autoloaded function
- beautysh strips indentation when pipe is at end of line (`cmd |` / `cmd2`), but preserves Google Shell Style with pipe at start (`cmd \` / `  | cmd2`) — always use Google style for multi-line pipes

### Issue 15 — Migrate fzf/
- `${functions_source[$0]:A:h}/__lib` is the cleanest pattern for autoloaded functions to find sibling `__lib/` dirs — shorter than hardcoding `$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/fzf/__lib/`
- Don't instrument code with fallbacks for testability — test through the public API instead (e.g., `--source`, `--regenerate-cache`)
- FZF preview/reload/execute-silent commands run in subprocesses where autoloaded functions aren't available — must use `bin-zsh <function-name>` wrapper for all fzf subprocess callbacks
- `exit 0` in sourced __lib/ files must be `return 0` — they execute in the calling function's scope, `exit` would kill the shell
- `shift-tab.zsh` also sourced fzf __lib/ — easy to miss since it's in keybindings/, not the fzf scripts dir

### Issue 18 — Migrate ai/ subdomains
- `plan-end` calls `claude-stop` which has no guard against test environments — tests must mock `claude-stop` to prevent killing the active Claude session (since `CLAUDECODE=1` leaks into bats subprocesses)
- `plan-badge` and `ralph-is-running` were already migrated in prior issues — their old test files in `scripts/bin/ai/ralph/__tests__/` were stale duplicates safe to delete
