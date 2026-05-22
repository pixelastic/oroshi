## Execution order

0001-preToolUse-Bash-solkan   → no blockers (parallel with 0002)
0002-preToolUse-Bash-rtk      → no blockers (parallel with 0001)
0003-preToolUse-Bash           → needs 0001 + 0002
0004-wire-Bash-matcher         → needs 0003

## Guidance

All issues follow TDD: write the failing BATS test first, run it to confirm it's red, then implement until it passes. Do not skip the red step.

`bats` and `zshlint` are in your $PATH.

Tests live in `config/ai/claude/hooks/__tests__/`. Each test file is named after the script it tests. No `load 'helper'` needed — tests call scripts directly.

Use `bats_tmp` for temp dirs. Call scripts directly (not via `run_zsh_fn` — these are executable scripts, not autoload functions).

New scripts go in:
  - config/ai/claude/hooks/   ← preToolUse-Bash-solkan, preToolUse-Bash-rtk (done)
  - preToolUse-Bash already exists there — issue 0003 replaces it entirely

Dependency injection in preToolUse-Bash:
  - PRETOOLUSE_SOLKAN_SCRIPT — defaults to $hookDir/preToolUse-Bash-solkan
  - PRETOOLUSE_RTK_SCRIPT    — defaults to $hookDir/preToolUse-Bash-rtk

In tests for preToolUse-Bash, create tiny mock scripts in bats_tmp:
  - mock-solkan-allow: #!/usr/bin/env zsh / exit 0
  - mock-solkan-ask:   #!/usr/bin/env zsh / exit 1
  - mock-rtk-pass:     #!/usr/bin/env zsh / echo "$1"
  - mock-rtk-rewrite:  #!/usr/bin/env zsh / echo "rtk $1"

Input to preToolUse-Bash is stdin JSON (Claude Code hook protocol — same as preToolUse dispatcher).
Output is hookSpecificOutput JSON to stdout.

Allowlist: config/ai/claude/hooks/allowlist.json
Domain: config/ai/claude/hooks/lib/hookLib.zsh

Issue 0004 (wire-Bash-matcher):
  - Add Bash matcher entry in ~/.claude/settings.json pointing to preToolUse-Bash
  - preToolUse-Bash reads from stdin (not $1 file arg — that was the dispatcher's calling convention)
  - Remove the Bash dispatch block from the preToolUse dispatcher
  - Remove the RTK hook entry from ~/.claude/settings.json
  - Delete ~/.claude/hooks/rtk-rewrite.sh

---
## Log (append below when an issue is completed)


## Session 2026-05-16 — 0001: preToolUse-Bash-solkan
- Completed: created `config/ai/claude/claudecode/hooks/preToolUse-Bash-solkan` — thin wrapper around `solkan` that resolves allowlist relative to `${0:A:h}`
- Tests added: `scripts/bin/__tests__/preToolUse-Bash-solkan.bats` — 10 tests covering simple allow/deny, &&, ||, ;, and pipe compound operators
- Discovered: `load 'test_helper/zsh'` mentioned in guidance doesn't exist; existing tests use `load 'helper'` — used that instead
- Fixed: none
- Skipped feedback: reviewer flagged `setopt local_options errexit` should be `set -e` for scripts — dismissed per memory (reviewer warnings on errexit are dismissed)
- Next: 0002-preToolUse-Bash-rtk (no blockers, parallel with 0001 which is now done)

## Session 2026-05-17 — 0002: preToolUse-Bash-rtk
- Completed: created `config/ai/claude/claudecode/hooks/preToolUse-Bash-rtk` — parses `rtk --help` to detect known subcommands, rewrites matching commands to `rtk <cmd>`, passes others unchanged, idempotent for already-prefixed commands
- Tests added: `scripts/bin/__tests__/preToolUse-Bash-rtk.bats` — 3 tests covering pass-through, rewrite, and idempotency
- Discovered: none
- Fixed: none
- Skipped feedback: reviewer flagged `local` at script top-level as invalid — dismissed: `zsh -c 'local x="hello"; print $x'` exits 0, zsh allows it; all other feedback targeted preToolUse-Bash-solkan (issue 0001, prior session)
- Next: 0003-preToolUse-Bash (orchestrator, needs 0001 + 0002 — both now done)

## Session 2026-05-22 — 0003: preToolUse-Bash orchestrator
- Completed: rewrote `config/ai/claude/hooks/preToolUse-Bash` — reads hook JSON from stdin, runs solkan+rtk in parallel, emits `hookSpecificOutput` JSON for all 4 allow/ask × rewrite/pass combinations
- Tests added: `config/ai/claude/hooks/__tests__/preToolUse-Bash.bats` — 5 tests covering all 4 output cases + description field preservation
- Discovered: `set -e` + `$rewritten` boolean (where `rewritten=false`) silently aborts script — `false` exits 1 and `set -e` treats it as fatal; fixed by using `[[ "$rewritten" == true ]]` throughout
- Fixed: restored deleted TEST CASES comments from original preToolUse-Bash; split grouped locals (`local var="$(cmd)"` pattern)
- Skipped feedback: bats `bats_load_library`/`run_zsh_script` pattern — guidance says "No load 'helper' needed, tests call scripts directly"; `rewritten` → `isRewritten` rename (judgment call, not a hard violation); solkan stdin contract (solkan reads positional arg `$1` per its source)
- Next: 0005-fix-rtk-rewrite-api (then 0006-fix-sequential-execution, then 0004-wire-Bash-matcher)

## Session 2026-05-22 — glossary + new issues 0005/0006
- Completed: created `__docs__/glossary.md` — shared vocabulary for the hook system (allow/reject, rewrite/ignore, auto-approve/ask, the 4 cases, execution order)
- Discovered: `rtk rewrite` is the canonical API for hooks ("single source of truth") — current `preToolUse-Bash-rtk` parsing `--help` is fragile → issue 0005
- Discovered: intended execution order is sequential (Solkan then RTK) — current implementation is parallel → issue 0006
- Fixed: prd.json last 0003 entry was still `"passes": false`
- Next: 0005 (fix rtk rewrite API) → 0006 (fix sequential execution) → 0004 (wire Bash matcher)
