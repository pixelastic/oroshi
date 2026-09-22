bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Simulated installed extension directory (where GNOME Shell reads)
  # reload uses $HOME/.local/share/gnome-shell/extensions/oroshi-statuses@oroshi
  INSTALLED_DIST="$BATS_TMP_DIR/.local/share/gnome-shell/extensions/oroshi-statuses@oroshi/dist"
  mkdir -p "$INSTALLED_DIST"

  # Simulated script location (e.g. a worktree)
  SCRIPT_DIR="$BATS_TMP_DIR/script-source"
  mkdir -p "$SCRIPT_DIR/lib"
  touch "$SCRIPT_DIR/lib/main.js"

  # Copy reload script to simulated location
  cp "$BATS_TEST_DIRNAME/../reload" "$SCRIPT_DIR/reload"

  # Mock gnome-extensions and uuid
  gnome-extensions() { :; }
  uuid() { echo "test-uuid-1234"; }
  bats_mock gnome-extensions uuid
}

@test "creates symlink in installed extension dist, not script-local dist" {
  bats_disable_worktree_aware

  bats_run_zsh "HOME=$BATS_TMP_DIR source $SCRIPT_DIR/reload"
  [[ "$status" -eq 0 ]]

  # Symlink exists in installed extension dist
  [[ -L "$INSTALLED_DIST/test-uuid-1234" ]]

  # No dist directory created in script-local lib
  [[ ! -d "$SCRIPT_DIR/lib/dist" ]]
}

@test "symlink points to the lib directory of the script's location" {
  bats_disable_worktree_aware

  bats_run_zsh "HOME=$BATS_TMP_DIR source $SCRIPT_DIR/reload"
  [[ "$status" -eq 0 ]]

  local target="$(readlink "$INSTALLED_DIST/test-uuid-1234")"
  [[ "$target" == "$SCRIPT_DIR/lib" ]]
}

@test "token file written to installed extension dist" {
  bats_disable_worktree_aware

  bats_run_zsh "HOME=$BATS_TMP_DIR source $SCRIPT_DIR/reload"
  [[ "$status" -eq 0 ]]

  [[ -f "$INSTALLED_DIST/token" ]]
  [[ "$(cat "$INSTALLED_DIST/token")" == "test-uuid-1234" ]]
}

@test "cleans up previous symlink before creating new one" {
  # Pre-existing token and symlink
  echo "old-uuid" > "$INSTALLED_DIST/token"
  ln -s "/some/old/path" "$INSTALLED_DIST/old-uuid"

  bats_disable_worktree_aware

  bats_run_zsh "HOME=$BATS_TMP_DIR source $SCRIPT_DIR/reload"
  [[ "$status" -eq 0 ]]

  # Old symlink removed
  [[ ! -e "$INSTALLED_DIST/old-uuid" ]]
  # New symlink created
  [[ -L "$INSTALLED_DIST/test-uuid-1234" ]]
}
