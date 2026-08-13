## Fix bare `cat` in FZF libs and sort-filepaths

`alias cat='better-cat'` in the interactive shell breaks FZF widgets. `better-cat` iterates `$@` as file paths (via `bat`) — it doesn't read stdin.

Sourced `__lib/*.zsh` files expand aliases at parse time → `cat` becomes `better-cat` → stdin never read.

### Symptoms

- **ctrl-p empty list:** `sort-filepaths` does `cat -` → `better-cat -` → treats `-` as filename → bat error → no output
- **ctrl-g selection lost:** `fzf-regexp-postprocess` does `$(cat)` → `$(better-cat)` → no args → empty loop → widget gets nothing

### Fix

Replace bare `cat` with `\cat` (alias-safe) in:
- `fzf/__lib/fzf-regexp-common.zsh` lines 44, 113
- `fzf/__lib/fzf-var.zsh` line 22
- `misc/sort-filepaths` line 14
