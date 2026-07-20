bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  echo "hello" > "$BATS_GIT_DIR/file.txt"
  bats_git add file.txt
  bats_git commit --quiet -m "initial"
}

@test "does nothing when working tree is clean" {
  bats_run_zsh "cd $BATS_GIT_DIR && git-file-edit"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "opens modified file in nvim" {
  echo "modified" > "$BATS_GIT_DIR/file.txt"
  filetypes-load-definitions() { :; }
  filetypes-group() { REPLY="text"; }
  nvim() { echo "$*"; }
  bats_mock filetypes-load-definitions filetypes-group nvim

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-edit"
  [ "$status" -eq 0 ]
  [[ "$output" == *"file.txt"* ]]
}

@test "does not open deleted files" {
  rm "$BATS_GIT_DIR/file.txt"
  filetypes-load-definitions() { :; }
  nvim() { echo "$*"; }
  bats_mock filetypes-load-definitions nvim

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-edit"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "accepts editable files" {
  echo "x" > "$BATS_GIT_DIR/app.js"
  echo "x" > "$BATS_GIT_DIR/func.zsh"
  echo "x" > "$BATS_GIT_DIR/note.txt"
  bats_git add .

  filetypes-load-definitions() { :; }
  filetypes-group() {
    local file="$2"
    case "${file:e}" in
      js|zsh) REPLY="script" ;;
      txt) REPLY="text" ;;
    esac
  }
  nvim() { echo "$*"; }
  bats_mock filetypes-load-definitions filetypes-group nvim

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-edit"
  [ "$status" -eq 0 ]
  [[ "$output" == *"app.js"* ]]
  [[ "$output" == *"func.zsh"* ]]
  [[ "$output" == *"note.txt"* ]]
}

@test "rejects binary files" {
  echo "x" > "$BATS_GIT_DIR/song.mp3"
  echo "x" > "$BATS_GIT_DIR/font.woff2"
  echo "x" > "$BATS_GIT_DIR/keep.txt"
  bats_git add .

  filetypes-load-definitions() { :; }
  filetypes-group() {
    local file="$2"
    case "${file:e}" in
      mp3) REPLY="audio" ;;
      woff2) REPLY="font" ;;
      txt) REPLY="text" ;;
    esac
  }
  nvim() { echo "$*"; }
  bats_mock filetypes-load-definitions filetypes-group nvim

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-edit"
  [ "$status" -eq 0 ]
  [[ "$output" == *"keep.txt"* ]]
  [[ "$output" != *"song.mp3"* ]]
  [[ "$output" != *"font.woff2"* ]]
}

@test "accepts files with unknown extensions" {
  echo "x" > "$BATS_GIT_DIR/data.xyz"
  bats_git add .

  filetypes-load-definitions() { :; }
  filetypes-group() { REPLY=""; }
  nvim() { echo "$*"; }
  bats_mock filetypes-load-definitions filetypes-group nvim

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-edit"
  [ "$status" -eq 0 ]
  [[ "$output" == *"data.xyz"* ]]
}

@test "still skips plan files" {
  mkdir -p "$BATS_GIT_DIR/plans/my-plan/scaffold"
  echo "x" > "$BATS_GIT_DIR/plans/my-plan/state.json"
  echo "x" > "$BATS_GIT_DIR/plans/my-plan/scaffold/template.lua"
  echo "x" > "$BATS_GIT_DIR/useful.txt"
  bats_git add .

  filetypes-load-definitions() { :; }
  filetypes-group() {
    local file="$2"
    case "${file:e}" in
      json) REPLY="config" ;;
      lua) REPLY="script" ;;
      txt) REPLY="text" ;;
    esac
  }
  nvim() { echo "$*"; }
  bats_mock filetypes-load-definitions filetypes-group nvim

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-edit"
  [ "$status" -eq 0 ]
  [[ "$output" == *"useful.txt"* ]]
  [[ "$output" != *"state.json"* ]]
  [[ "$output" != *"template.lua"* ]]
}

@test "does not open renamed source file (old path no longer exists)" {
  git -C "$BATS_GIT_DIR" mv file.txt renamed.txt
  filetypes-load-definitions() { :; }
  filetypes-group() { REPLY="text"; }
  nvim() { echo "$*"; }
  bats_mock filetypes-load-definitions filetypes-group nvim

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-edit"
  [ "$status" -eq 0 ]
  [[ "$output" == *"renamed.txt"* ]]
  [[ "$output" != *"file.txt"* ]]
}
