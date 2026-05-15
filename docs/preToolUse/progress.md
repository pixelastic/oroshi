## Execution order

0001-preToolUse-Bash-solkan   → no blockers (parallel with 0002)
0002-preToolUse-Bash-rtk      → no blockers (parallel with 0001)
0003-preToolUse-Bash           → needs 0001 + 0002
0004-wire-Bash-matcher         → needs 0003

## Guidance

All issues follow TDD: write the failing BATS test first, run it to confirm it's red, then implement until it passes. Do not skip the red step.

`bats` and `zshlint` are in your $PATH.

Tests live in `scripts/bin/__tests__/`. Each test file is named after the script it tests.

Use the shared helper — `load 'test_helper/zsh'` — for running zsh scripts. Use `bats_tmp` for temp dirs. Call scripts directly (not via `run_zsh_fn` — these are executable scripts, not autoload functions).

New scripts go in:
  - config/ai/claude/claudecode/hooks/   ← preToolUse-Bash, preToolUse-Bash-solkan, preToolUse-Bash-rtk

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

Allowlist: config/ai/claude/claudecode/hooks/allowlist.json
Domain: config/ai/claude/claudecode/hooks/lib/hookLib.zsh

Issue 0004 (wire-Bash-matcher):
  - Add Bash matcher entry in ~/.claude/settings.json pointing to preToolUse-Bash
  - preToolUse-Bash reads from stdin (not $1 file arg — that was the dispatcher's calling convention)
  - Remove the Bash dispatch block from the preToolUse dispatcher
  - Remove the RTK hook entry from ~/.claude/settings.json
  - Delete ~/.claude/hooks/rtk-rewrite.sh

---
## Log (append below when an issue is completed)
