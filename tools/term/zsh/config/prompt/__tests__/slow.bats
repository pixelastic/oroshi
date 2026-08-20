bats_load_library 'helper'

setup() {
  bats_tmp_dir
  kitty-notify() { printf '%s' "$*" > "$BATS_TMP_DIR/kitty-notify-args"; }
  bats_mock kitty-notify
}

# Helper: source slow.zsh and call the precmd function with given exit status
# and a command duration exceeding the threshold (400s > 300s threshold)
run_slow_precmd() {
  local exitCode="${1:-0}"
  local duration="${2:-400}"
  bats_run_zsh "
    add-zsh-hook() { :; }
    source '$BATS_TEST_DIRNAME/../slow.zsh'
    oroshiSlowCommandStartTime=\$((SECONDS - $duration))
    (exit $exitCode); oroshiSlowCommandPrecmd
  "
}

@test "calls kitty-notify --sound slow-success.mp3 on slow success" {
  run_slow_precmd 0
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/kitty-notify-args")" = "--sound slow-success.mp3" ]]
}

@test "calls kitty-notify --sound slow-failure.mp3 on slow failure" {
  run_slow_precmd 1
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/kitty-notify-args")" = "--sound slow-failure.mp3" ]]
}

@test "does not call kitty-notify for short commands" {
  run_slow_precmd 0 100
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/kitty-notify-args" ]]
}
