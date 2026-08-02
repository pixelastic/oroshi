## Issue 01 — is-claude
### Potentially unnecessary bats_tmp_dir
```bash
setup() {
  bats_tmp_dir
}
```
**Problem:** `bats_tmp_dir` called in setup but `$BATS_TMP_DIR` not directly used in tests.
**Reason skipped:** `bats_mock_env` may use it internally; all existing test files follow this pattern for consistency.

## Issue 02 — Subagent detection
### set -e contradicts prior decision
```zsh
set -e
```
**Problem:** Memory `project_hook_bash_rewrite.md` says not to re-add `set -e` globally
**Reason skipped:** Initially added then reverted — memory was correct. Hook must always exit 0; `set -e` would cause non-zero exit on any command failure, making Claude bypass permission logic. Added `zsh-lint disable-file=missingSetE` instead

### No guard after local assignment
```zsh
local agentId="$(json-get '.agent_id' <<<"$inputJson")"
[[ "$agentId" != "" ]] && updatedInputCommand="export CLAUDE_IS_SUBAGENT=1; $updatedInputCommand"
```
**Problem:** Missing explicit guard after local assignment per variables.md
**Reason skipped:** Empty agentId is the normal no-subagent case, not a failure; one-liner conditional handles it correctly

### Injection timing before Solkan/RTK
```zsh
local agentId="$(json-get '.agent_id' <<<"$inputJson")"
[[ "$agentId" != "" ]] && updatedInputCommand="export CLAUDE_IS_SUBAGENT=1; $updatedInputCommand"
```
**Problem:** Spec says injection should happen before Solkan/RTK
**Reason skipped:** Prefixing before Solkan would cause it to parse `export` as a command and reject; current position (after RTK, before output helpers) achieves the spec's goal of all output paths carrying the prefix
