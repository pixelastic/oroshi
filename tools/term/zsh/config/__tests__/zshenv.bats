bats_load_library 'helper'

setup() {
  bats_tmp_dir
  CURRENT="$BATS_TMP_DIR/caller.zsh"
  ZSHENV="$OROSHI_ROOT/tools/term/zsh/config/zshenv.zsh"

  # Real git repo for worktree tests
  # NOTE: bats_git_worktree can't be used — bats_slugify collapses -- to -,
  # but detection requires oroshi--* paths. Create worktree directly.
  bats_git_dir
  WORKTREES_DIR="$BATS_TMP_DIR/worktrees"
  WT_ROOT="$WORKTREES_DIR/oroshi--myrepo"
  mkdir -p "$WORKTREES_DIR"
  git -C "$BATS_GIT_DIR" worktree add --quiet -b "oroshi--myrepo" "$WT_ROOT"

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
  printf 'unset OROSHI_ROOT; export MOCK_OROSHI_WORKTREES_DIR="%s"; cd "%s"; source "%s"; echo "$OROSHI_ROOT"\n' \
    "$WORKTREES_DIR" "$WT_ROOT" "$ZSHENV" >"$CURRENT"
  bats_run_zsh "source '$CURRENT'"
  [ "$status" -eq 0 ]
  [ "$output" = "$WT_ROOT" ]
}

@test "OROSHI_ROOT is set to worktree root when PWD is inside a worktree subdir" {
  mkdir -p "$WT_ROOT/some/subdir"
  printf 'unset OROSHI_ROOT; export MOCK_OROSHI_WORKTREES_DIR="%s"; cd "%s"; source "%s"; echo "$OROSHI_ROOT"\n' \
    "$WORKTREES_DIR" "$WT_ROOT/some/subdir" "$ZSHENV" >"$CURRENT"
  bats_run_zsh "source '$CURRENT'"
  [ "$status" -eq 0 ]
  [ "$output" = "$WT_ROOT" ]
}

@test "OROSHI_ROOT stays default when in a non-oroshi worktree" {
  local otherWT
  otherWT="$(bats_git_worktree 'other-project')"
  local fakeHome="$BATS_TMP_DIR/home"
  mkdir -p "$fakeHome/.oroshi/tools/term/zsh/config/functions"
  printf "function oroshi-reload-path() { :; }\n" >"$fakeHome/.oroshi/tools/term/zsh/config/path.zsh"
  printf "# noop\n" >"$fakeHome/.oroshi/tools/term/zsh/config/functions/noop.zsh"
  printf 'export HOME="%s"; unset OROSHI_ROOT; export MOCK_OROSHI_WORKTREES_DIR="%s"; cd "%s"; source "%s"; echo "$OROSHI_ROOT"\n' \
    "$fakeHome" "$WORKTREES_DIR" "$otherWT" "$ZSHENV" >"$CURRENT"
  bats_run_zsh "source '$CURRENT'"
  [ "$status" -eq 0 ]
  [ "$output" = "$fakeHome/.oroshi" ]
}

@test "OROSHI_ROOT defaults to HOME/.oroshi when PWD is outside OROSHI_WORKTREES_DIR" {
  local fakeHome="$BATS_TMP_DIR/home"
  mkdir -p "$fakeHome/.oroshi/tools/term/zsh/config/functions"
  printf "function oroshi-reload-path() { :; }\n" >"$fakeHome/.oroshi/tools/term/zsh/config/path.zsh"
  printf "# noop\n" >"$fakeHome/.oroshi/tools/term/zsh/config/functions/noop.zsh"
  printf 'export HOME="%s"; unset OROSHI_ROOT; export MOCK_OROSHI_WORKTREES_DIR="%s"; source "%s"; echo "$OROSHI_ROOT"\n' \
    "$fakeHome" "$WORKTREES_DIR" "$ZSHENV" >"$CURRENT"
  bats_run_zsh "source '$CURRENT'"
  [ "$status" -eq 0 ]
  [ "$output" = "$fakeHome/.oroshi" ]
}
