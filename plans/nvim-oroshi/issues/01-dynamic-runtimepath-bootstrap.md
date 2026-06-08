## TLDR

Rename the Lua config directory to follow NeoVim conventions, then update `init.lua` to load everything from `$OROSHI_ROOT` via runtimepath.

## What to build

Three tightly-coupled changes that together make NeoVim load its config from `$OROSHI_ROOT` at startup:

**1. Directory rename**
Rename `tools/vim/nvim/config/config/` to `tools/vim/nvim/config/lua/oroshi/` using `git mv`. This aligns the structure with NeoVim's runtimepath convention (`{runtimepath}/lua/<namespace>/`), so that `require("oroshi/X")` resolves natively. No import paths change in any of the 72 existing Lua files.

**2. `init.lua` bootstrap**
Update the entry point to read `vim.env.OROSHI_ROOT`, prepend `$OROSHI_ROOT/tools/vim/nvim/config` to `vim.opt.runtimepath`, then call `require("oroshi/index")`. This is the only file that must be merged to main before the feature is fully active — the deploy symlink always points to main's `init.lua`.

**3. Deploy script simplification**
Remove the two now-redundant symlinks (`lua/oroshi` and `after/`) from the deploy script. NeoVim finds both directories automatically via the runtimepath entry. Keep the `init.lua` symlink and the `swap/undo/view` directory creation.

## Behavioral Tests

Skip — pure structural refactor, no new behavior to unit-test. Manual verification: launch NeoVim with `$OROSHI_ROOT` pointing to the worktree and confirm the worktree config loads.

## Scaffolding Tests

Skip — no scaffolding test framework for Lua or deploy scripts in this project.

## Acceptance criteria

- [ ] `tools/vim/nvim/config/lua/oroshi/` exists and contains all 72 previously-existing Lua files
- [ ] `tools/vim/nvim/config/config/` no longer exists
- [ ] `init.lua` reads `vim.env.OROSHI_ROOT` and prepends the config root to runtimepath before requiring `oroshi/index`
- [ ] `require("oroshi/X")` works correctly at runtime (no broken imports)
- [ ] `after/queries/` treesitter overrides load from `$OROSHI_ROOT` (verified by runtimepath, not symlink)
- [ ] Deploy script no longer creates `lua/oroshi` or `after/` symlinks
- [ ] NeoVim launched with `$OROSHI_ROOT` = `~/.oroshi` behaves identically to before
- [ ] NeoVim write locations (swap, undo, view, plugins, shada) remain global and unaffected
