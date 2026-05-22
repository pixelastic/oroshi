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

**No tests** — migration is verified manually by inspecting the file tree and spot-checking path references. Do not write bats tests or any automated tests for these issues.

---
## Log (append below when an issue is completed)

## Session 2026-05-22 — 0004: cli domain fully migrated to tools/cli/

- Completed: Moved 13 install scripts, 5 deploy scripts (bat, fd, nnn, rg, tldr), and 3 config dirs (bat, fd, rg) into tools/cli/. Updated deploy scripts to use $(dirname "$0")/config (bash) or ${0:h}/config (zsh). Added deploy call at end of install scripts for bat, fd, nnn, rg, tldr. Updated RIPGREP_CONFIG_PATH in config/term/zsh/tools/rg.zsh to use $OROSHI_ROOT/tools/cli/rg/config/. Removed empty scripts/install/cli/, scripts/deploy/cli/, config/cli/. Fixed local at script scope in nnn/deploy.
- Discovered: No index file existed in scripts/install/cli/ (no install-all needed). No config/cli/tldr/ exists (tldr/deploy has stale ref to non-existent config — predates this migration).
- Fixed: local at script scope removed from nnn/deploy.
- Skipped feedback: ${0:h} vs $(dirname "$0") — bat/install, nnn/install, tldr/install all have #!/usr/bin/env zsh; same pattern as prior sessions. Missing tldr/config/ — never existed. Missing install-all — no index file to convert.
- Next: issue-005 (docker domain migration)

## Session 2026-05-22 — 0003: basics domain fully migrated to tools/basics/

- Completed: Moved 10 install scripts, 5 deploy scripts, and 7 config directories into tools/basics/. Updated deploy scripts to use ${0:h}/config (zsh) or $(dirname "$0")/config (bash). Removed empty scripts/install/basics/, scripts/deploy/basics/, config/basics/.
- Discovered: No install scripts have a sibling deploy (installs are simple apt-get calls; deploys are apt-get, editorconfig, hosts, ssh, wget — none have a matching install). dircolors has config only (no install, no deploy). hosts and ssh deploys reference ~/.oroshi/private/config/basics/ for private local overrides — these are intentionally kept as absolute paths since private configs are not part of this migration.
- Fixed: Removed `local` from CONFIG_DIR in zsh deploy scripts (local at script scope is semantically incorrect).
- Skipped feedback: ${0:h} vs $(dirname "$0") — kept zsh idiom for zsh scripts (same as 0001/0002); private ~/.oroshi/private/config paths kept as-is (not part of migration); reviewer's claim that fonts/install has a sibling deploy is incorrect (fonts/deploy doesn't exist).
- Next: issue-004 (cli domain migration)

## Session 2026-05-22 — 0002: audio domain fully migrated to tools/audio/

- Completed: Moved all 9 audio install scripts (aac, abcde, cmus, flac, id3, mp3, ogg, sox, whisper) to tools/audio/{tool}/install. Moved config/audio/sounds to tools/audio/sounds/config. Converted index → install-all with ${0:h} relative paths, rewrote to cover all tools and drop stale mplayer reference. Removed empty scripts/install/audio/ and config/audio/.
- Discovered: index was stale — referenced old `music/` domain and omitted abcde, id3, whisper. No deploy scripts exist; no install→deploy wiring needed.
- Fixed: install-all rewritten to cover all actual tools; mplayer (stale, never in audio domain) dropped.
- Skipped feedback: ${0:h} vs $(dirname "$0") — same as issue-001, kept ${0:h}; sounds treated as a tool (sounds config → tools/audio/sounds/config/); mplayer never existed in scripts/install/audio/ so dropping is correct.
- Next: issue-003 (basics domain migration)

## Session 2026-05-22 — 0001: ai domain fully migrated to tools/ai/

- Completed: Moved all ai domain files (claudecode→claude, claude-blog, humanizer, rtk, skills installs; claude+rtk deploys; claude+rtk configs) to tools/ai/. Updated deploy scripts to use ${0:h}/config. Added deploy calls at end of install scripts. Updated all cross-tool refs in hooks + settings.json.
- Discovered: scripts/deploy/ai/rtk and config/ai/rtk existed (not listed in issue detail) — migrated both. Hook scripts and settings.json had hardcoded old paths that needed updating.
- Fixed: local at script scope in deploy removed; missing headers added to deploy scripts; POSIX brackets in deploy replaced with [[]]
- Skipped feedback: $(dirname "$0") vs ${0:h} — spec example used dirname but ${0:h} is cleaner zsh; kept ${0:h}
- Next: issue-002 (audio domain migration)
