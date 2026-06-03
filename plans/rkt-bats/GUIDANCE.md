## Guidance

**Testing:** Run `rtk bats <filepath>` to run bats tests. Run `zshlint <filepath>` to lint zsh files.

**Autoload location:** Zsh autoloaded functions live in `tools/term/zsh/config/functions/autoload/{domain}/{subdomain}/`. The new `rtk-can-rewrite` function goes in the `ai/rtk` subdomain. Its bats tests go alongside it (check prior art in other autoload subdomains for the `__tests__/` convention).

**Hook location:** `tools/ai/claude/config/hooks/` — standalone scripts, not autoloaded. Tests live in `hooks/__tests__/`.

**Stale file:** `hooks/__tests__/rtk-can-rewrite.bats` was created as an early draft and must be deleted in issue 01 — the real tests live with the autoload function.

**Domain vocabulary:** See `tools/ai/claude/config/hooks/GLOSSARY.md`. RTK layer makes a binary **rewrite / ignore** decision. `rtk-can-rewrite` is the new mechanism for that decision (replaces direct `rtk rewrite` call).

**Env var conventions:**
- `RTK_CAN_REWRITE_CMD` — `rtk-can-rewrite` path override (used inside `preToolUse-Bash-rtk` for test isolation)
- `$OROSHI_ROOT` — canonical path to oroshi repo root; use instead of hardcoded paths

**Prior art for tests:** `hooks/__tests__/preToolUse-Bash-rtk.bats` shows the mock pattern (`printf '#!/usr/bin/env zsh\n...'` + `chmod +x`).

## Discoveries

### Issue 01 — rtk-can-rewrite
- Use `$OROSHI_ROOT` for oroshi paths, not hardcoded `~/.oroshi`
- Don't add env var overrides (RTK_CMD, RTK_FILTERS_TOML) to prod code for test isolation — use bats mock system
- `grep -qP` for single-match TOML lookups instead of extracting all names + looping
