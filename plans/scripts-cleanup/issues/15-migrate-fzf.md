## Migrate fzf/ to autoloaded (complex)

All 12 scripts + `__lib/` (18 files) → autoloaded functions.

### Key challenge

Scripts source `__lib/` files via `${0:a:h}/__lib/init.zsh`. After migration to autoloaded functions, `${0:a:h}` won't resolve to the right directory. Must adapt path resolution (e.g., use `$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/fzf/__lib/`).

### Scripts

ctrl-b, ctrl-g, ctrl-o, ctrl-p, ctrl-r, ctrl-shift-g, ctrl-shift-p, fzf-bats-test, fzf-docker-images, fzf-git-commits, fzf-git-files-deleted, fzf-plans

### __lib/ files to move

All 18 .zsh files in `__lib/` → `autoload/fzf/__lib/`

### Keybindings to verify

ZSH keybindings call these by name — should work after migration since autoloaded functions are in PATH.
