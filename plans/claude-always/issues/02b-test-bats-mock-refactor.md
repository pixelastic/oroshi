## TLDR

Refactor tests to use `bats_mock` + `bats_run_script` so each test defines solkan/rtk behavior inline as functions, consistent with the rest of the bats codebase.

## What to build

Replace the current disk-based mock script approach with inline function mocks. Three changes:

**1. Hook: call solkan and rtk by function name** — remove `PRETOOLUSE_SOLKAN_SCRIPT` / `PRETOOLUSE_RTK_SCRIPT` env var mechanism. The hook sources its sibling scripts at load time to define `solkan` and `rtk` as functions. Sourcing is conditional so bats_mock can override them in tests:

```zsh
(( ${+functions[solkan]} )) || source "${hookDir}/preToolUse-Bash-solkan"
(( ${+functions[rtk]} ))    || source "${hookDir}/preToolUse-Bash-rtk"
```

**2. Sibling scripts: define functions instead of being standalone executables** — `preToolUse-Bash-solkan` and `preToolUse-Bash-rtk` define a `solkan` / `rtk` function respectively (no shebang, not chmod +x).

**3. Tests: use `bats_load_library 'helper'` + `bats_mock` + `bats_run_script`** — setup exports env vars, each test defines its own mocks inline:

```bash
setup() {
  bats_tmp_dir
  SCRIPT="$(dirname "$BATS_TEST_FILENAME")/../preToolUse-Bash"
  export CLAUDE_HOOKS_LOG_DIR="$BATS_TMP_DIR"
  export CLAUDE_SESSIONS_DIR="$BATS_TMP_DIR"
}

teardown() { bats_cleanup; }

@test "ask when solkan rejects wget" {
  solkan() { print '{"isAllowed":false,"commands":{"rejected":["wget"]}}'; return 1; }
  bats_mock solkan

  rtk() { print -- "$1"; }
  bats_mock rtk

  bats_run_script "$SCRIPT" <<< '{"tool_name":"Bash","tool_input":{"command":"wget evil.com"}}'
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq -r '.hookSpecificOutput.permissionDecision')" = "ask" ]
}
```

Note: verify that stdin via `<<<` propagates through `bats_run_script` → `run zsh -c`. If not, add a tmp-file fallback to `bats_run_script`.

## Acceptance criteria

- [ ] Hook sources sibling scripts conditionally (guard on `${+functions[solkan]}` / `${+functions[rtk]}`)
- [ ] Hook no longer reads `PRETOOLUSE_SOLKAN_SCRIPT` or `PRETOOLUSE_RTK_SCRIPT`
- [ ] `preToolUse-Bash-solkan` defines a `solkan` function (not a standalone script)
- [ ] `preToolUse-Bash-rtk` defines a `rtk` function (not a standalone script)
- [ ] Tests use `bats_load_library 'helper'`, `bats_tmp_dir`, `bats_cleanup`
- [ ] Each test mocks `solkan` and `rtk` inline via `bats_mock`
- [ ] Tests use `bats_run_script` instead of `run env ... "$SCRIPT"`
- [ ] `CLAUDE_HOOKS_LOG_DIR` and `CLAUDE_SESSIONS_DIR` exported in setup
- [ ] All existing test scenarios covered (allow, ask, rtk rewrite, ordering)
