bats_load_library 'helper'

setup() {
  bats_tmp_dir
  local script="$BATS_TEST_DIRNAME/../__lib/ralph-single.zsh"
  CURRENT="$BATS_TMP_DIR/caller.zsh"
  export PRD_DIR="$BATS_TMP_DIR/prd-dir"

  mkdir -p "$PRD_DIR"
  printf 'ralph-single "$@"\n' >"$CURRENT"
  printf "source '%s'\n" "$script" >"$BATS_TMP_DIR/mock.zsh"
}

teardown() { bats_cleanup; }

# ── Semaphore ───────────────────────────────────────────────────────────────

@test "refuses to run when ralph.json with mode=single already exists" {
  jo mode=single done=false prd_done=false >"$PRD_DIR/ralph.json"
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() { return 0; }
  bats_mock git-directory-root claude

  bats_run_zsh "$CURRENT" "$PRD_DIR"
  [ "$status" -eq 1 ]
}

@test "proceeds normally when no ralph.json exists" {
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() { return 0; }
  ralph-state() { true; }
  bats_mock git-directory-root claude ralph-state

  bats_run_zsh "$CURRENT" "$PRD_DIR"
  [ "$status" -eq 0 ]
}

@test "proceeds normally when ralph.json exists with mode=loop" {
  jo mode=loop done=false prd_done=false >"$PRD_DIR/ralph.json"
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() { return 0; }
  ralph-state() {
    [[ "$2" == "get" ]] && echo "loop" && return 0
    return 0
  }
  bats_mock git-directory-root claude ralph-state

  bats_run_zsh "$CURRENT" "$PRD_DIR"
  [ "$status" -eq 0 ]
}

# ── Session lifecycle ────────────────────────────────────────────────────────

@test "creates ralph.json before launching Claude" {
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() { [ -f "$PRD_DIR/ralph.json" ]; }
  bats_mock git-directory-root claude

  bats_run_zsh "$CURRENT" "$PRD_DIR"
  [ "$status" -eq 0 ]
}

@test "clears ralph.json after Claude exits (happy path)" {
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() { return 0; }
  bats_mock git-directory-root claude

  bats_run_zsh "$CURRENT" "$PRD_DIR"
  [ "$status" -eq 0 ]
  [ ! -f "$PRD_DIR/ralph.json" ]
}

@test "clears ralph.json after Claude exits with non-zero status" {
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() { touch "$BATS_TMP_DIR/claude-called"; return 1; }
  bats_mock git-directory-root claude

  bats_run_zsh "$CURRENT" "$PRD_DIR"
  [ -f "$BATS_TMP_DIR/claude-called" ]
  [ ! -f "$PRD_DIR/ralph.json" ]
}

# ── Claude invocation ────────────────────────────────────────────────────────

@test "calls Claude with the correct plan directory argument" {
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  claude() { echo "ARGS:$*"; }
  ralph-state() { true; }
  bats_mock git-directory-root claude ralph-state

  bats_run_zsh "$CURRENT" "$PRD_DIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"/ralph ${PRD_DIR}"* ]]
}
