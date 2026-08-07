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
- All ZSH code → autoloaded functions (line 1 = `# Description`, use `setopt local_options err_return`)
- External callers (NeoVim, Kitty, Ubuntu keybindings, cron) call via `bin-zsh <function>`
- Naming: `domain-action` pattern (e.g. `git-commit-cancel`, `png-alpha`)
- When migrating: remove shebang, move doc to line 1, replace `set -e` with `setopt local_options err_return`

### Audit decisions
The full per-script audit (keep/delete/rename decisions) is at `/tmp/oroshi/claude/scripts/scripts-audit-decisions.md`. Copy it into the plan directory if it needs to survive across sessions.

### External callers to update to `bin-zsh`
After migrating a script to autoloaded function, grep for call sites in:
1. NeoVim (`F.run` and `vim.fn.system` in `tools/editors/neovim/`)
2. Kitty keybindings (`tools/term/kitty/config/keybindings.conf`)
3. Kitty statusbar (`tools/term/kitty/config/lib/statusbar.py`)
4. Ubuntu keybindings (`tools/ubuntu/24.04/keybindings/custom`)
5. Argos GNOME panel (`tools/ubuntu/24.04/argos/config/`)

### Prior art
- Existing lint rules: see `scripts/bin/zsh/zsh-lint/__rules/` for pattern
- Existing lint rule tests: see `scripts/bin/zsh/zsh-lint/__rules/__tests/` for bats test pattern

## Discoveries

(append-only, updated by agents after each issue)

### Issue 02 — Rules, glossary, naming
- All ZSH code is autoloaded functions — no more ZSH scripts in `scripts/bin/`
- `bin-zsh` dispatcher replaces per-function `-bin` wrappers — one script calls any autoloaded function from non-ZSH contexts
- `missingScriptJustification` lint rule removed — no ZSH scripts means no `# Script because:` needed
- `bin-zsh` knowledge lives in guidance and issue 03b, not in zsh-writer or glossary (caller concern, not writer concern)
- Domain issues (04-16) follow: migrate to autoloaded function → update external call sites to `bin-zsh <function>`

### Issue 01 — Delete dead code
- `scripts/etc/` directory doesn't exist — no orphan cleanup needed
- `bats-echo` was already deleted before this issue
- `cpv` (copy-verbose) and `mvv` (move-verbose) aliases in cp.zsh/mv.zsh also needed removal — not listed in issue but caught by broken-reference grep
- `trr` (trash-restore) alias was a duplicate of `rmz` — removed alongside `tr?`/`trl`
- Remark npm packages in package.json needed cleanup alongside the config files
- `cheats/zsh/parse-args.zsh` had a stale `(argsf, argsp)` parenthetical

### Issue 03b — bin-zsh dispatcher
- Both existing `-bin` wrappers (`colorize-bin`, `git-directory-root-bin`) had zero external callers — call-site migration was a no-op
- `echoerr` helper exists and is enforced by zsh-lint rule `useEchoerr` — use it instead of `echo ... >&2`

### Issue 05 — Video/media domain
- Rename map was wrong for conversions: `X2Y` is the established convention (not `X-to-Y`). Rename map updated.
- `-min` is the compression suffix (matches `html-min`, `gifmin`, `pngmin`), not `-compress`
- `compdef.zsh` had a pre-existing typo: `video-increase-volume` instead of `video-volume-increase` — fixed as part of reference updates
- `dds2png` belongs in `img/` root (not `img/png/`, not `video/`)
- `bin2iso` belongs in `misc/` (disc image, not video)
- ffmpeg/ffprobe/mencoder/vcdxrip only have single-dash flags — long-form arg rule doesn't apply
