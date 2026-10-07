bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "returns 1 when the lockfile does not exist" {
  bats_run_zsh "lockfile-is-active $BATS_TMP_DIR/missing.lock"
  [[ "$status" -eq 1 ]]
}

@test "returns 0 when the lockfile holds the PID of a live process" {
  local lockfile="$BATS_TMP_DIR/live.lock"
  sleep 30 &
  local livePid=$!
  echo "$livePid" > "$lockfile"

  bats_run_zsh "lockfile-is-active $lockfile"
  kill "$livePid"

  [[ "$status" -eq 0 ]]
  [[ -f "$lockfile" ]]
}

@test "returns 1 and removes the lockfile when its PID is dead" {
  local lockfile="$BATS_TMP_DIR/dead.lock"
  sleep 0.1 &
  local deadPid=$!
  wait "$deadPid"
  echo "$deadPid" > "$lockfile"

  bats_run_zsh "lockfile-is-active $lockfile"

  [[ "$status" -eq 1 ]]
  [[ ! -f "$lockfile" ]]
}
