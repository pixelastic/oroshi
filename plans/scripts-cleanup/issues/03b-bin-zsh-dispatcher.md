## TLDR

Create `bin-zsh`, a single dispatcher script that calls any autoloaded ZSH function from non-ZSH contexts.

## What to build

A script at `scripts/bin/bin-zsh` that:
1. Takes a function name as first argument, remaining args forwarded
2. Calls `"$@"` — ZSH autoload environment is already available via `.zshenv`
3. Propagates exit code correctly

Usage: `bin-zsh git-branch-current --verbose`

This replaces all per-function `-bin` wrappers. External callers (NeoVim `F.run`, Kitty keybindings, Ubuntu keybindings, cron) use `bin-zsh <function>` instead of calling a script directly.

### Migration of existing `-bin` wrappers

Find and replace all existing `-bin` wrapper scripts:
- `colorize-bin` → callers use `bin-zsh colorize`
- `git-directory-root-bin` → callers use `bin-zsh git-directory-root`
- Any others found by grepping for `-bin` scripts

Update all call sites in:
- `tools/editors/neovim/` (`F.run`, `vim.fn.system`)
- `tools/term/kitty/config/keybindings.conf`
- `tools/term/kitty/config/lib/statusbar.py`
- `tools/ubuntu/24.04/keybindings/custom`
- `tools/ubuntu/24.04/argos/config/`

Delete the old `-bin` wrapper files after migration.

## Behavioral Tests

- calls a known autoloaded function and returns its output
- forwards arguments correctly
- propagates non-zero exit codes
- fails with usage message when called without arguments

## Acceptance criteria

- [ ] `bin-zsh` script exists and is executable
- [ ] All existing `-bin` wrappers replaced by `bin-zsh` call sites
- [ ] All call sites updated (NeoVim, Kitty, Ubuntu keybindings, Argos)
- [ ] Old `-bin` wrapper files deleted
- [ ] Tests pass
