## TLDR

Rename `oroshi-reload-functions` → `oroshi-reload-fpath` and replace its string-hack argument with a proper `[root]` arg.

## What to build

`oroshi-reload-functions` already handles fpath correctly — it removes previously tracked fpath
dirs, rebuilds them from the config path, and re-registers all autoloaded functions. It just has
the wrong name and a fragile argument interface (`"worktree"` string hack).

Rename the function to `oroshi-reload-fpath`. Replace the `"worktree"` branch with an explicit
optional `[root]` argument (same contract as `oroshi-reload-path`): when provided, rebuild fpath
and autoloads from that root's `tools/term/zsh/config/functions/autoload/`; when omitted, use
the current `ZSH_CONFIG_PATH`.

Rename the file from `oroshi-reload-functions.zsh` to `oroshi-reload-fpath.zsh` to match.

Update the call site in `zshenv.zsh` to use the new name (no argument needed there — init always
uses the current root).

## Behavioral Tests

**Given a non-default root argument:**
- `fpath` contains the `functions/autoload/` subdirectories of the given root
- A function that exists only in the given root's autoload tree is correctly autoloaded
- `fpath` does not contain `functions/autoload/` dirs from `~/.oroshi` (previously loaded dirs are removed)

**Given no argument:**
- `fpath` and autoloaded functions match what the current `ZSH_CONFIG_PATH` provides

## Scaffolding Tests

- `oroshi-reload-functions` (old name) is not defined after shell init

## Acceptance criteria

- [ ] `oroshi-reload-fpath` is callable after shell init
- [ ] `oroshi-reload-fpath <worktree-root>` rebuilds `fpath` and autoloads from that root
- [ ] `oroshi-reload-fpath` with no args behaves identically to the current `oroshi-reload-functions` call
- [ ] `oroshi-reload-functions` (old name) no longer exists
- [ ] File renamed from `oroshi-reload-functions.zsh` to `oroshi-reload-fpath.zsh`
- [ ] Behavioral tests pass
