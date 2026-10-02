bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Simulated tool location with its own config dir
  TOOL_DIR="$BATS_TMP_DIR/timers"
  mkdir -p "$TOOL_DIR/config"
  cp "$BATS_TEST_DIRNAME/../deploy" "$TOOL_DIR/deploy"

  # Where systemd user units are symlinked
  DEST_DIR="$BATS_TMP_DIR/.config/systemd/user"

  # Capture systemctl invocations instead of touching the real daemon
  systemctl() { echo "$*" >> "$BATS_TMP_DIR/systemctl-calls"; }
  bats_mock systemctl
}

@test "symlinks each timer and service into the user systemd dir" {
  touch "$TOOL_DIR/config/foo.timer" "$TOOL_DIR/config/foo.service"
  bats_disable_worktree_aware

  bats_run_zsh "HOME=$BATS_TMP_DIR source $TOOL_DIR/deploy"
  [[ "$status" -eq 0 ]]

  [[ -L "$DEST_DIR/foo.timer" ]]
  [[ -L "$DEST_DIR/foo.service" ]]
  [[ "$(readlink "$DEST_DIR/foo.timer")" == "$TOOL_DIR/config/foo.timer" ]]
  [[ "$(readlink "$DEST_DIR/foo.service")" == "$TOOL_DIR/config/foo.service" ]]
}

@test "reloads the daemon then enables each timer" {
  touch "$TOOL_DIR/config/foo.timer" "$TOOL_DIR/config/foo.service"
  bats_disable_worktree_aware

  bats_run_zsh "HOME=$BATS_TMP_DIR source $TOOL_DIR/deploy"
  [[ "$status" -eq 0 ]]

  run grep --fixed-strings -- "--user daemon-reload" "$BATS_TMP_DIR/systemctl-calls"
  [[ "$status" -eq 0 ]]
  run grep --fixed-strings -- "--user enable --now foo.timer" "$BATS_TMP_DIR/systemctl-calls"
  [[ "$status" -eq 0 ]]
}

@test "does not enable services, only timers" {
  touch "$TOOL_DIR/config/foo.timer" "$TOOL_DIR/config/foo.service"
  bats_disable_worktree_aware

  bats_run_zsh "HOME=$BATS_TMP_DIR source $TOOL_DIR/deploy"
  [[ "$status" -eq 0 ]]

  run grep --fixed-strings "enable --now foo.service" "$BATS_TMP_DIR/systemctl-calls"
  [[ "$status" -ne 0 ]]
}

@test "empty config returns cleanly without touching systemd" {
  bats_disable_worktree_aware

  bats_run_zsh "HOME=$BATS_TMP_DIR source $TOOL_DIR/deploy"
  [[ "$status" -eq 0 ]]

  [[ ! -e "$BATS_TMP_DIR/systemctl-calls" ]]
  [[ ! -d "$DEST_DIR" ]]
}

@test "is idempotent across repeated runs" {
  touch "$TOOL_DIR/config/foo.timer"
  bats_disable_worktree_aware

  bats_run_zsh "HOME=$BATS_TMP_DIR source $TOOL_DIR/deploy"
  [[ "$status" -eq 0 ]]
  bats_run_zsh "HOME=$BATS_TMP_DIR source $TOOL_DIR/deploy"
  [[ "$status" -eq 0 ]]

  [[ -L "$DEST_DIR/foo.timer" ]]
}
