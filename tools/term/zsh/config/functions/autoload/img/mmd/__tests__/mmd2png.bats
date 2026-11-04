bats_load_library 'helper'

setup() {
  bats_disable_worktree_aware
  bats_tmp_dir
  printf 'flowchart TD\n  A[Start] --> B[End]\n' >"$BATS_TMP_DIR/a.mmd"
}

@test "writes the png next to the source" {
  bats_run_zsh "mmd2png $BATS_TMP_DIR/a.mmd"
  [[ "$status" -eq 0 ]]
  [[ "$(file --brief --mime-type "$BATS_TMP_DIR/a.png")" == "image/png" ]]
}

@test "leaves no svg when none existed before" {
  bats_run_zsh "mmd2png $BATS_TMP_DIR/a.mmd"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_TMP_DIR/a.svg" ]]
}

@test "keeps an svg that existed before" {
  echo "original" >"$BATS_TMP_DIR/a.svg"
  bats_run_zsh "mmd2png $BATS_TMP_DIR/a.mmd"
  [[ "$status" -eq 0 ]]
  [[ "$(<"$BATS_TMP_DIR/a.svg")" == "original" ]]
  [[ -f "$BATS_TMP_DIR/a.png" ]]
}

@test "refuses to overwrite an existing png and hints about --force" {
  echo "original" >"$BATS_TMP_DIR/a.png"
  bats_run_zsh "mmd2png $BATS_TMP_DIR/a.mmd"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"--force"* ]]
  [[ "$(<"$BATS_TMP_DIR/a.png")" == "original" ]]
}

@test "overwrites an existing png with --force" {
  echo "original" >"$BATS_TMP_DIR/a.png"
  bats_run_zsh "mmd2png --force $BATS_TMP_DIR/a.mmd"
  [[ "$status" -eq 0 ]]
  [[ "$(file --brief --mime-type "$BATS_TMP_DIR/a.png")" == "image/png" ]]
}

@test "overwrites an existing png with -f" {
  echo "original" >"$BATS_TMP_DIR/a.png"
  bats_run_zsh "mmd2png -f $BATS_TMP_DIR/a.mmd"
  [[ "$status" -eq 0 ]]
  [[ "$(file --brief --mime-type "$BATS_TMP_DIR/a.png")" == "image/png" ]]
}

@test "keeps a pre-existing svg untouched with --force" {
  echo "original" >"$BATS_TMP_DIR/a.svg"
  bats_run_zsh "mmd2png --force $BATS_TMP_DIR/a.mmd"
  [[ "$status" -eq 0 ]]
  [[ "$(<"$BATS_TMP_DIR/a.svg")" == "original" ]]
  [[ -f "$BATS_TMP_DIR/a.png" ]]
}

@test "fails on a missing source file" {
  bats_run_zsh "mmd2png $BATS_TMP_DIR/missing.mmd"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"missing.mmd"* ]]
  [[ ! -e "$BATS_TMP_DIR/missing.png" ]]
}

@test "fails on invalid Mermaid syntax and leaves no output" {
  echo "this is not mermaid" >"$BATS_TMP_DIR/bad.mmd"
  bats_run_zsh "mmd2png $BATS_TMP_DIR/bad.mmd"
  [[ "$status" -ne 0 ]]
  [[ ! -e "$BATS_TMP_DIR/bad.png" ]]
  [[ ! -e "$BATS_TMP_DIR/bad.svg" ]]
}

@test "opens nothing" {
  img-open() { echo "img-open $*" >>"$BATS_TMP_DIR/opened"; }
  xdg-open() { echo "xdg-open $*" >>"$BATS_TMP_DIR/opened"; }
  bats_mock img-open xdg-open

  bats_run_zsh "mmd2png $BATS_TMP_DIR/a.mmd"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$BATS_TMP_DIR/opened" ]]
}
