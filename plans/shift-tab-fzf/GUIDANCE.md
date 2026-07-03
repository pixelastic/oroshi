## Guidance

- Worktree: `~/local/www/worktrees/oroshi--shift-tab-fzf`, branch `shift-tab-fzf`
- fzf-tab is installed at `~/local/etc/fzf-tab/fzf-tab.zsh` — do NOT use `$OROSHI_ROOT` for this path, it is external to the repo
- Linting: `zsh-lint <filepath>` for zsh files
- No tests for this plan — all changes are config artifacts
- Prior art for keybinding widget pattern: `tools/term/zsh/config/keybindings/ctrl-b.zsh`
- Prior art for static fzf prompt badge: `scripts/bin/fzf/ctrl-b` (uses `fzf-options-prompt-label`)
- Prior art for `PROMPT_PREVENT_REFRESH` wrapper: `tools/term/zsh/config/keybindings/tab.zsh`
- Icon definitions file: `tools/term/zsh/config/theming/icons.zsh` — add `fzf-completion` after `fzf-history` in the fzf section
- fzf-tab hijacks `^I` on source via `enable-fzf-tab` — must revert `^I` → `oroshi-tab-widget` immediately after sourcing
- `fzf-options-prompt-label` helper: `scripts/bin/fzf/__lib/fzf-options-prompt-label.zsh`

## Discoveries

### Issue 01 — Shift-Tab fzf completion
- NerdFont glyphs in `icons.zsh` are invisible in Read output — Edit tool cannot match them; use `sed -i` with line numbers to insert after the target line.
- Inline `$(...)` inside a `zstyle` call is evaluated at source time (not lazily) — equivalent to pre-computing into a variable.

