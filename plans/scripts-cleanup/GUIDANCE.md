## Guidance

### Testing commands
- `bats <filepath>` — run bats tests
- `zsh-lint <filepath>` — lint ZSH files
- `bats-lint <filepath>` — lint bats files

### Key file locations (relative to repo root)
- `scripts/bin/` — all scripts
- `tools/term/zsh/config/functions/autoload/` — all autoloaded functions
- `tools/term/zsh/config/aliases/` — alias definitions
- `tools/editors/neovim/` — NeoVim config (references scripts via F.run())
- `tools/term/kitty/config/keybindings.conf` — Kitty keybindings
- `tools/term/kitty/config/lib/statusbar.py` — Kitty statusbar (calls statusbar-* scripts)
- `tools/ubuntu/24.04/keybindings/custom` — Ubuntu keybindings
- `tools/ubuntu/24.04/argos/config/` — Argos GNOME panel
- `scripts/bin/zsh/zsh-lint/__rules/` — custom zsh-lint rules
- `GLOSSARY.md` — domain glossary
- `CLAUDE.md` — developer conventions

### Conventions
- Autoloaded functions: line 1 = `# Description`, use `setopt local_options err_return`
- Scripts: line 1 = shebang, line 2 = `# Description`, line 3 = `# Script because:`, use `set -e`
- `-bin` suffix: thin script wrapper for autoloaded functions callable from external contexts
- Naming: `domain-action` pattern (e.g. `git-commit-cancel`, `png-alpha`)
- When migrating: remove shebang, move doc to line 1, replace `set -e` with `setopt local_options err_return`

### Audit decisions
The full per-script audit (keep/delete/rename decisions) is at `/tmp/oroshi/claude/scripts/scripts-audit-decisions.md`. Copy it into the plan directory if it needs to survive across sessions.

### External callers to check before migrating a script
A script must stay as a script if called from any of these:
1. NeoVim (grep `F.run` and `vim.fn.system` in `tools/editors/neovim/`)
2. Kitty keybindings (`tools/term/kitty/config/keybindings.conf`)
3. Kitty statusbar (`tools/term/kitty/config/lib/statusbar.py`)
4. Ubuntu keybindings (`tools/ubuntu/24.04/keybindings/custom`)
5. Argos GNOME panel (`tools/ubuntu/24.04/argos/config/`)

### Prior art
- Existing `-bin` wrapper: `git-directory-root-bin` wraps `git-directory-root`
- Existing lint rules: see `scripts/bin/zsh/zsh-lint/__rules/` for pattern
- Existing lint rule tests: see `scripts/bin/zsh/zsh-lint/__rules/__tests/` for bats test pattern

## Discoveries

(append-only, updated by agents after each issue)

### Issue 01 — Delete dead code
- `scripts/etc/` directory doesn't exist — no orphan cleanup needed
- `bats-echo` was already deleted before this issue
- `cpv` (copy-verbose) and `mvv` (move-verbose) aliases in cp.zsh/mv.zsh also needed removal — not listed in issue but caught by broken-reference grep
- `trr` (trash-restore) alias was a duplicate of `rmz` — removed alongside `tr?`/`trl`
- Remark npm packages in package.json needed cleanup alongside the config files
- `cheats/zsh/parse-args.zsh` had a stale `(argsf, argsp)` parenthetical
