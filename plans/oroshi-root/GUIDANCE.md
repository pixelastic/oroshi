## Guidance

### Goal

Make `OROSHI_ROOT` worktree-aware so every zsh process (interactive, NeoVim subshell,
`zsh -c`, pre-commit) automatically resolves tools from the correct oroshi root — the active
worktree root when inside one, `~/.oroshi` otherwise.

### Key files

- `tools/term/zsh/config/zshenv.zsh` — sets `OROSHI_ROOT` and derived vars; sourced by every zsh process
- `tools/term/zsh/config/path.zsh` — defines PATH-building logic (`oroshi_path` → `oroshi-reload-path`)
- `tools/term/zsh/config/functions/oroshi-reload-functions.zsh` → will become `oroshi-reload-fpath.zsh`

### Testing commands

- **Run bats tests:** `bats <filepath>`
- **Run zsh-lint:** `zsh-lint <filepath>`
- **Run bats-lint:** `bats-lint <filepath>`

### Testing approach for reload functions

Tests run each function in a subshell with a synthetic root (a temp directory that mimics the
oroshi scripts/bin and functions/autoload structure). Assert on `$PATH` and `$fpath` array
contents. Prior art: `tools/term/bats/config/helper` for the bats subshell pattern.

### Conventions

- Functions use hyphen naming: `oroshi-reload-path`, `oroshi-reload-fpath`
- Optional root arg defaults to `$OROSHI_ROOT` when omitted
- Worktree detection: string prefix check of `$PWD` against `$OROSHI_WORKTREES_DIR` (no subprocess)
- Worktree root extraction: strip first path component after `$OROSHI_WORKTREES_DIR/`

### Manual verification (issues 01 and 04)

For issue 01: open a new terminal with `$PWD` inside a worktree, run `echo $OROSHI_ROOT` — should
show the worktree path. Run `which bats-lint` — should resolve to the worktree's `scripts/bin/`.

For issue 04: in a running session, `cd` into a worktree, run `echo $OROSHI_ROOT` — should switch.
`cd` back out, should revert.

## Discoveries

### Issue 01 — zshenv worktree detection

- `OROSHI_ZSH_AUTOLOAD` was not pre-existing; it was added here as `$OROSHI_ROOT/tools/term/zsh/config/functions/autoload`.
- Testing `zshenv.zsh` requires a minimal fake worktree structure (`path.zsh` + `functions/noop.zsh`) so sourcing the file doesn't fail when `OROSHI_ROOT` points to the fake root. Also requires mocking `oroshi-reload-functions` in setup() to prevent the real function (sourced from `functions/oroshi-reload-functions.zsh`) from overriding the mock.
- The default-fallback test (OROSHI_ROOT → `$HOME/.oroshi`) must fake `$HOME` via the caller script to avoid hitting the real `~/.oroshi` install.
