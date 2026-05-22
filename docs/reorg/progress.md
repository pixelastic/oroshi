## Execution order

issue-001 → start here, no blockers (ai)
issue-002 → start here, no blockers (audio)
issue-003 → start here, no blockers (basics)
issue-004 → start here, no blockers (cli)
issue-005 → start here, no blockers (docker)
issue-006 → start here, no blockers (git)
issue-007 → start here, no blockers (image)
issue-008 → start here, no blockers (infrastructure)
issue-009 → start here, no blockers (keybindings)
issue-010 → start here, no blockers (_languages)
issue-011 → start here, no blockers (misc)
issue-012 → start here, no blockers (ubuntu)
issue-013 → start here, no blockers (vim)
issue-014 → start here, no blockers (windows)
issue-015 → start here, no blockers (worktools)
issue-016 → needs issue-001 through issue-015 (term — contains ZSH configs cross-referencing all other domains)
issue-017 → needs issue-001 through issue-016 (cleanup — delete old directory trees)

## Guidance

**Repository**: oroshi — personal dotfiles and tooling monorepo
**Working directory**: `/home/tim/local/www/worktrees/oroshi--reorg` (worktree on branch `reorg`)
**Deployed as**: `~/.oroshi` (symlink)

**Migration pattern per tool** (apply in this order for each tool):
1. `git mv scripts/install/{domain}/{tool} tools/{domain}/{tool}/install`
2. `git mv scripts/deploy/{domain}/{tool} tools/{domain}/{tool}/deploy` (if exists)
3. `git mv config/{domain}/{tool} tools/{domain}/{tool}/config` (if exists — directory, not file)
4. In `tools/{domain}/{tool}/deploy`: replace `~/.oroshi/config/{domain}/{tool}/` with `$(dirname "$0")/config/`
5. In `tools/{domain}/{tool}/install`: add `"$(dirname "$0")/deploy"` as last line (only if deploy exists)
6. For cross-tool refs in moved files: replace `~/.oroshi/config/{domain}/{tool}/` with `$OROSHI_ROOT/tools/{domain}/{tool}/config/`

**index → install-all**:
- `git mv scripts/install/{domain}/index tools/{domain}/install-all`
- Update internal calls from `~/.oroshi/scripts/install/{domain}/{tool}` to `"$(dirname "$0")/{tool}/install"`

**Naming**:
- `img` → `image` (domain rename)
- `claudecode` → `claude` (tool rename)
- `_languages` keeps the underscore

**ubuntu special case**:
- No install scripts (Ubuntu pre-installed)
- Version is an intermediate level: `tools/ubuntu/{version}/{feature}/`
- Each sub-feature (autostart, keybindings, topbar, tweaks…) is its own tool with deploy + config/

**Path variables**:
- `$OROSHI_ROOT` is already defined in ZSH env (`~/.oroshi`)
- Intra-tool: `$(dirname "$0")/config` — relocatable, no variable needed
- Cross-tool: `$OROSHI_ROOT/tools/{domain}/{tool}/config/`

**Do not touch**:
- `scripts/bin/`
- `scripts/etc/`
- `scripts/yarn/`

**One commit per domain** — keeps the history readable and rollback cheap.

---
## Log (append below when an issue is completed)

## Session 2026-05-22 — 0001: ai domain fully migrated to tools/ai/

- Completed: Moved all ai domain files (claudecode→claude, claude-blog, humanizer, rtk, skills installs; claude+rtk deploys; claude+rtk configs) to tools/ai/. Updated deploy scripts to use ${0:h}/config. Added deploy calls at end of install scripts. Updated all cross-tool refs in hooks + settings.json.
- Discovered: scripts/deploy/ai/rtk and config/ai/rtk existed (not listed in issue detail) — migrated both. Hook scripts and settings.json had hardcoded old paths that needed updating.
- Fixed: local at script scope in deploy removed; missing headers added to deploy scripts; bats test hardcoded path replaced with git rev-parse; POSIX brackets in deploy replaced with [[]]
- Skipped feedback: $(dirname "$0") vs ${0:h} — spec example used dirname but ${0:h} is cleaner zsh; kept ${0:h}
- Next: issue-002 (audio domain migration)
