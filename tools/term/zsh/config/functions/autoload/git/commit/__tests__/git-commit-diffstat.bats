bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Mock collaborators
  git-commit-current() { echo "abc1234"; }
  git-commit-exists() { return 0; }
  go-run-oroshi() { echo "$@" > "$BATS_TMP_DIR/go-run-args.txt"; }
  bats_mock git-commit-current git-commit-exists go-run-oroshi
}

# --- Argument parsing ---

@test "accepts positional old-ref as first argument" {
  bats_run_zsh "git-commit-diffstat def5678"
  [[ "$status" -eq 0 ]]
}

@test "accepts --to flag with a value" {
  bats_run_zsh "git-commit-diffstat def5678 --to xyz9999"
  [[ "$status" -eq 0 ]]
  local args="$(cat "$BATS_TMP_DIR/go-run-args.txt")"
  [[ "$args" == *"xyz9999"* ]]
}

@test "accepts --repo flag with a value" {
  bats_run_zsh "git-commit-diffstat def5678 --repo $BATS_TMP_DIR"
  [[ "$status" -eq 0 ]]
  local args="$(cat "$BATS_TMP_DIR/go-run-args.txt")"
  [[ "$args" == *"$BATS_TMP_DIR"* ]]
}

@test "defaults --to to HEAD when omitted" {
  bats_run_zsh "git-commit-diffstat def5678"
  local args="$(cat "$BATS_TMP_DIR/go-run-args.txt")"
  [[ "$args" == *"abc1234"* ]]
}

@test "defaults --repo to PWD when omitted" {
  bats_run_zsh "cd /tmp && git-commit-diffstat def5678"
  local args="$(cat "$BATS_TMP_DIR/go-run-args.txt")"
  [[ "$args" == *"/tmp"* ]]
}

# --- Validation ---

@test "exits 1 with error message when no positional arg provided" {
  bats_run_zsh "git-commit-diffstat"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"Usage"* ]]
}

@test "exits 1 with error message when from ref does not exist" {
  git-commit-exists() { [[ "$1" != "bad-ref" ]] && return 0 || return 1; }
  bats_mock git-commit-exists

  bats_run_zsh "git-commit-diffstat bad-ref"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"bad-ref"* ]]
}

@test "exits 1 with error message when to ref does not exist" {
  git-commit-exists() { [[ "$1" != "bad-to" ]] && return 0 || return 1; }
  bats_mock git-commit-exists

  bats_run_zsh "git-commit-diffstat good-from --to bad-to"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"bad-to"* ]]
}

# --- Delegation ---

@test "calls go-run-oroshi with from, to, and repo as positional args" {
  bats_run_zsh "git-commit-diffstat def5678 --to xyz9999 --repo $BATS_TMP_DIR"
  [[ "$status" -eq 0 ]]
  local args="$(cat "$BATS_TMP_DIR/go-run-args.txt")"
  [[ "$args" == "git-commit-diffstat def5678 xyz9999 $BATS_TMP_DIR" ]]
}
