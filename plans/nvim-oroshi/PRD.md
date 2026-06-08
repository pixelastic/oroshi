## Problem Statement

When launching NeoVim from an oroshi worktree, the editor loads its Lua configuration from a hardcoded location (a static symlink set at deploy time), ignoring the current value of `$OROSHI_ROOT`. This makes it impossible to test NeoVim config changes in a worktree before merging them to main — the live NeoVim session always reflects the main branch, not the worktree under development.

Additionally, one path in the statusline module is hardcoded to `~/.oroshi`, bypassing `$OROSHI_ROOT` entirely.

## Solution

Make NeoVim's bootstrap (`init.lua`) read `$OROSHI_ROOT` at startup and dynamically add the correct config tree to the runtimepath. The directory structure is aligned with NeoVim conventions so that `require("oroshi/X")` continues to work without any symlink tricks. The deploy script is simplified accordingly.

After the change: launching NeoVim while `$OROSHI_ROOT` points to a worktree loads that worktree's Lua config. When `$OROSHI_ROOT` points to `~/.oroshi` (the default), behavior is identical to today.

## User Stories

1. As a developer working in an oroshi worktree, I want NeoVim to load its Lua config from `$OROSHI_ROOT`, so that I can test my NeoVim config changes live without merging to main first.
2. As a developer on the main branch, I want NeoVim behavior to be unchanged when `$OROSHI_ROOT` = `~/.oroshi`, so that the migration is transparent.
3. As a developer, I want `require("oroshi/X")` to keep working in all Lua modules, so that no import paths need to change across the 72 existing files.
4. As a developer, I want treesitter query overrides (`after/queries/`) to also load from `$OROSHI_ROOT`, so that syntax changes in a worktree are testable immediately.
5. As a developer, I want the statusline's project data path to respect `$OROSHI_ROOT`, so that a worktree with theming changes reflects the correct projects list.
6. As a developer, I want NeoVim's write locations (swap, undo, view, plugin data, shada) to remain global and unaffected by `$OROSHI_ROOT`, so that worktree sessions don't pollute the repository with runtime artifacts.
7. As a developer running `deploy` for a fresh machine setup, I want the deploy script to remain simple and correct, so that the global config is bootstrapped with a single command.

## Implementation Decisions

### Module A — Directory rename + `init.lua` bootstrap

The config Lua directory is renamed from its current location to follow the NeoVim runtimepath convention: `lua/<namespace>/`. This allows NeoVim to resolve `require("oroshi/X")` natively once `$OROSHI_ROOT/tools/vim/nvim/config` is in the runtimepath.

`init.lua` (the symlinked entry point, always loaded from main) is updated to:
1. Read `vim.env.OROSHI_ROOT`
2. Prepend `$OROSHI_ROOT/tools/vim/nvim/config` to `vim.opt.runtimepath`
3. Call `require("oroshi/index")`

This is the only file that must be merged to main before the feature is fully active — the symlink always points to main's `init.lua`.

### Module B — Deploy script simplification

The deploy script currently creates three symlinks: `init.lua`, `lua/oroshi`, and `after`. With the runtimepath approach, the latter two are redundant — NeoVim finds `lua/oroshi/` and `after/` automatically once the runtimepath entry is set. The deploy script is reduced to the `init.lua` symlink and the creation of the `swap/undo/view` data directories.

### Module C — Statusline path fix

The single hardcoded `~/.oroshi/...` path in the statusline module is replaced with `vim.env.OROSHI_ROOT .. "/..."`, consistent with how all other external-command paths are already written in the codebase.

### Architectural constraints

- `$OROSHI_ROOT` is always set by zshenv — no fallback is needed in Lua.
- The runtimepath change is read-only: NeoVim's write paths (`stdpath("data")`, `stdpath("state")`, `stdpath("cache")`, swap/undo/view) are controlled by separate options and remain global.
- The config loading is evaluated once at NeoVim startup. Hot-reloading `$OROSHI_ROOT` mid-session is out of scope.
- Module A and Module B are tightly coupled and should be implemented together.

## Testing Decisions

No automated tests are written for this feature.

- NeoVim Lua has no test framework in this project.
- Deploy script changes are config artifacts — the symlink and directory structure are the test.
- The correct behavior is verified manually: launch NeoVim from a worktree, confirm it loads the worktree's config.

## Out of Scope

- Hot-reloading `$OROSHI_ROOT` during an active NeoVim session.
- Per-worktree plugin data (lazy.nvim plugins remain global).
- Changes to any Lua `require("oroshi/X")` call sites — none need to change.
- The worktree itself benefiting from the feature before Module A is merged to main (acceptable bootstrap constraint).

## Further Notes

The rename in Module A is a `git mv` — git preserves file history. No import paths change in the 72 existing Lua files.
