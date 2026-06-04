## Guidance

**Goal:** Strip Whisper hallucination artifacts from `wav2txt-openai` output.

**Target file:** `scripts/bin/audio/wav2txt-openai`

**Test file:** `scripts/bin/audio/__tests__/wav2txt-openai.bats`

**Testing:**
- Run bats tests: `bats scripts/bin/audio/__tests__/wav2txt-openai.bats`
- Lint: `zsh-lint scripts/bin/audio/wav2txt-openai`

**Conventions:**
- Functions and constants are defined before the execution guard
- `ARTIFACTS` is a script-level constant (UPPER_CASE, no `local`)
- Exact phrase matching via `sed` — no regex
- Bats tests use `bats_load_library 'helper'`, `bats_tmp_dir` in setup, `bats_cleanup` in teardown
- Use `bats_run_script` to source the script in tests; mock `source` builtin to skip credential loading

**Prior art:**
- Source-safe guard pattern: `[[ "$ZSH_EVAL_CONTEXT" == "toplevel" ]]`
- Bats mock pattern: see `tools/term/bats/config/helper` for `bats_mock` and `bats_run_script`
- Similar bats test structure: `scripts/bin/misc/__tests__/better-rm.bats`

## Discoveries

<!-- Agents append findings here after each issue -->

### Issue 01 — wav2txt-openai source-safe guard
- `[[ condition ]] || return` is disallowed by `noOrGuard` zshlint rule; invert to `[[ ! condition ]] && return`
- The `source` builtin mock must be a passthrough (call `builtin source "$@"` for non-private paths) so `bats_run_script`'s own `source '${script}'` call still loads the file
- Scripts with shebangs need `set -e`; this was missing and must be added when touching such files
