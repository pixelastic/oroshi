bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Fake oroshi root with both helper roots
  export AUTOLOAD_DIR="$BATS_TMP_DIR/tools/term/zsh/config/functions/autoload"
  export SCRIPTS_DIR="$BATS_TMP_DIR/scripts/bin"
  mkdir -p "$AUTOLOAD_DIR" "$SCRIPTS_DIR"
}

@test "lists an autoloaded function by name" {
  mkdir -p "$AUTOLOAD_DIR/git"
  touch "$AUTOLOAD_DIR/git/git-branch-list"

  bats_run_zsh "OROSHI_ROOT='$BATS_TMP_DIR' complete-helpers"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "git-branch-list" ]]
}

@test "lists a script from the bin directory by name" {
  touch "$SCRIPTS_DIR/my-script"

  bats_run_zsh "OROSHI_ROOT='$BATS_TMP_DIR' complete-helpers"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "my-script" ]]
}

@test "excludes files under a __lib, __tests__ or __docs directory" {
  mkdir -p "$AUTOLOAD_DIR/git/__lib" "$AUTOLOAD_DIR/git/__tests__" "$SCRIPTS_DIR/__docs"
  touch "$AUTOLOAD_DIR/git/git-branch-list"
  touch "$AUTOLOAD_DIR/git/__lib/init.zsh"
  touch "$AUTOLOAD_DIR/git/__tests__/git-branch-list.bats"
  touch "$SCRIPTS_DIR/__docs/readme.md"

  bats_run_zsh "OROSHI_ROOT='$BATS_TMP_DIR' complete-helpers"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "git-branch-list" ]]
}

@test "prints names only, with no description or path" {
  mkdir -p "$AUTOLOAD_DIR/git"
  printf '# Switch branch\n' > "$AUTOLOAD_DIR/git/git-branch-switch"

  bats_run_zsh "OROSHI_ROOT='$BATS_TMP_DIR' complete-helpers"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "git-branch-switch" ]]
}

@test "prints names sorted" {
  touch "$SCRIPTS_DIR/zebra" "$SCRIPTS_DIR/alpha"
  mkdir -p "$AUTOLOAD_DIR/git"
  touch "$AUTOLOAD_DIR/git/middle"

  bats_run_zsh "OROSHI_ROOT='$BATS_TMP_DIR' complete-helpers"
  [[ "$status" -eq 0 ]]
  [[ "${lines[*]}" == "alpha middle zebra" ]]
}

@test "prints a name once when it exists in both roots" {
  mkdir -p "$AUTOLOAD_DIR/git"
  touch "$AUTOLOAD_DIR/git/shared-name"
  touch "$SCRIPTS_DIR/shared-name"

  bats_run_zsh "OROSHI_ROOT='$BATS_TMP_DIR' complete-helpers"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "shared-name" ]]
}

@test "prints nothing when both roots are empty" {
  bats_run_zsh "OROSHI_ROOT='$BATS_TMP_DIR' complete-helpers"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}
