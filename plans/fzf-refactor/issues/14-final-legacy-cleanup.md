## TLDR

Remove all remaining Legacy FZF autoloads and evaluate ctrl-shift-i (Claude sessions). (HITL)

## What to build

By this point all FZF Scripts have been migrated and each issue has deleted its own legacy
autoloads. This issue handles whatever remains.

**Remaining legacy autoloads to delete:**
- `helpers/` autoloads (`fzf-var-write`, `fzf-var-read`, `fzf-prompt-directory`, `fzf-prompt-pwd`)
  — replaced by FZF Helpers sourced directly
- `bin/fzf-search` — the legacy orchestrator, no longer called by anything
- `fs/shared/fzf-fs-shared-zsh-filters` — verify no remaining callers
- Any autoloads not yet deleted by previous issues

**Evaluate ctrl-shift-i (Claude sessions):**
The Claude sessions search was kept in legacy throughout the migration. At this point, decide:
- **Migrate**: implement `scripts/bin/fzf/ctrl-shift-i` with improved session discovery
  (chronological list, better search) — add as a follow-up issue if the scope is significant
- **Remove**: delete the keybinding and legacy autoloads if no good implementation is found

This issue is HITL because the ctrl-shift-i decision requires user judgement.

**Verify no legacy autoload directory survives:**
After cleanup, `tools/term/zsh/config/functions/autoload/fzf/` should be empty or removed.

## Acceptance criteria

- [ ] `fzf-var-write`, `fzf-var-read` legacy autoloads deleted (replaced by helpers)
- [ ] `fzf-prompt-directory`, `fzf-prompt-pwd` legacy autoloads deleted
- [ ] `bin/fzf-search` deleted
- [ ] All remaining `fs/shared/` autoloads deleted
- [ ] `autoload/fzf/` directory is empty and removed
- [ ] Decision made on ctrl-shift-i: migrated (new issue created) or deleted
- [ ] `zshlint` passes on all modified files
- [ ] Full manual smoke test: all keybindings work as expected
