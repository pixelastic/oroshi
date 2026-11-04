bats_load_library 'helper'

setup() {
  bats_disable_worktree_aware
  bats_tmp_dir
  printf 'flowchart TD\n  A[Start] --> B[End]\n' >"$BATS_TMP_DIR/a.mmd"
}

@test "writes the svg next to the source" {
  bats_run_zsh "mmd2svg $BATS_TMP_DIR/a.mmd"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/a.svg" ]]
  [[ "$(<"$BATS_TMP_DIR/a.svg")" == *"<svg"* ]]
}

@test "refuses to overwrite an existing output and hints about --force" {
  echo "original" >"$BATS_TMP_DIR/a.svg"
  bats_run_zsh "mmd2svg $BATS_TMP_DIR/a.mmd"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"--force"* ]]
  [[ "$(<"$BATS_TMP_DIR/a.svg")" == "original" ]]
}

@test "overwrites an existing output with --force" {
  echo "original" >"$BATS_TMP_DIR/a.svg"
  bats_run_zsh "mmd2svg --force $BATS_TMP_DIR/a.mmd"
  [[ "$status" -eq 0 ]]
  [[ "$(<"$BATS_TMP_DIR/a.svg")" == *"<svg"* ]]
}

@test "overwrites an existing output with -f" {
  echo "original" >"$BATS_TMP_DIR/a.svg"
  bats_run_zsh "mmd2svg -f $BATS_TMP_DIR/a.mmd"
  [[ "$status" -eq 0 ]]
  [[ "$(<"$BATS_TMP_DIR/a.svg")" == *"<svg"* ]]
}

@test "fails on a missing source file" {
  bats_run_zsh "mmd2svg $BATS_TMP_DIR/missing.mmd"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"missing.mmd"* ]]
  [[ ! -e "$BATS_TMP_DIR/missing.svg" ]]
}

@test "fails on invalid Mermaid syntax and leaves no output" {
  echo "this is not mermaid" >"$BATS_TMP_DIR/bad.mmd"
  bats_run_zsh "mmd2svg $BATS_TMP_DIR/bad.mmd"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Invalid mermaid header"* ]]
  [[ ! -e "$BATS_TMP_DIR/bad.svg" ]]
}

@test "opens nothing" {
  img-open() { echo "img-open $*" >>"$BATS_TMP_DIR/opened"; }
  xdg-open() { echo "xdg-open $*" >>"$BATS_TMP_DIR/opened"; }
  bats_mock img-open xdg-open

  bats_run_zsh "mmd2svg $BATS_TMP_DIR/a.mmd"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_TMP_DIR/opened" ]]
}
