bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="$BATS_TMP_DIR/caller.zsh"
  ZSHENV="$OROSHI_ROOT/tools/term/zsh/config/zshenv.zsh"

  # Real git repo for worktree tests
  bats_git_dir
  WT_ROOT="$(bats_git_worktree "wt")"
  WORKTREES_DIR="$BATS_TMP_DIR/worktrees"

  # Minimal fake structure so zshenv.zsh can source its deps safely
  mkdir -p "$WT_ROOT/tools/term/zsh/config/functions"
  printf "function oroshi-reload-path() { :; }\n" >"$WT_ROOT/tools/term/zsh/config/path.zsh"
  printf "# noop\n" >"$WT_ROOT/tools/term/zsh/config/functions/noop.zsh"

  # Mock oroshi-reload-fpath as no-op so it does not rebuild fpath
  oroshi-reload-fpath() { :; }
  bats_mock oroshi-reload-fpath
}

teardown() {
  bats_cleanup
}

# --- Worktree detection ---

@test "OROSHI_ROOT is set to worktree root when PWD is at the worktree root" {
  printf 'unset OROSHI_ROOT; export OROSHI_WORKTREES_DIR_MOCK="%s"; cd "%s"; source "%s"; echo "$OROSHI_ROOT"\n' \
    "$WORKTREES_DIR" "$WT_ROOT" "$ZSHENV" >"$CURRENT"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "$WT_ROOT" ]
}

@test "OROSHI_ROOT is set to worktree root when PWD is inside a worktree subdir" {
  mkdir -p "$WT_ROOT/some/subdir"
  printf 'unset OROSHI_ROOT; export OROSHI_WORKTREES_DIR_MOCK="%s"; cd "%s"; source "%s"; echo "$OROSHI_ROOT"\n' \
    "$WORKTREES_DIR" "$WT_ROOT/some/subdir" "$ZSHENV" >"$CURRENT"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "$WT_ROOT" ]
}

@test "OROSHI_ROOT defaults to HOME/.oroshi when PWD is outside OROSHI_WORKTREES_DIR" {
  local fakeHome="$BATS_TMP_DIR/home"
  mkdir -p "$fakeHome/.oroshi/tools/term/zsh/config/functions"
  printf "function oroshi-reload-path() { :; }\n" >"$fakeHome/.oroshi/tools/term/zsh/config/path.zsh"
  printf "# noop\n" >"$fakeHome/.oroshi/tools/term/zsh/config/functions/noop.zsh"
  printf 'export HOME="%s"; unset OROSHI_ROOT; export OROSHI_WORKTREES_DIR_MOCK="%s"; source "%s"; echo "$OROSHI_ROOT"\n' \
    "$fakeHome" "$WORKTREES_DIR" "$ZSHENV" >"$CURRENT"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "$fakeHome/.oroshi" ]
}

# --- Derived variables ---

@test "ZSH_CONFIG_PATH reflects detected OROSHI_ROOT" {
  printf 'unset OROSHI_ROOT; export OROSHI_WORKTREES_DIR_MOCK="%s"; cd "%s"; source "%s"; echo "$ZSH_CONFIG_PATH"\n' \
    "$WORKTREES_DIR" "$WT_ROOT" "$ZSHENV" >"$CURRENT"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "$WT_ROOT/tools/term/zsh/config" ]
}

@test "OROSHI_ZSH_AUTOLOAD reflects detected OROSHI_ROOT" {
  printf 'unset OROSHI_ROOT; export OROSHI_WORKTREES_DIR_MOCK="%s"; cd "%s"; source "%s"; echo "$OROSHI_ZSH_AUTOLOAD"\n' \
    "$WORKTREES_DIR" "$WT_ROOT" "$ZSHENV" >"$CURRENT"
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "$WT_ROOT/tools/term/zsh/config/functions/autoload" ]
}
