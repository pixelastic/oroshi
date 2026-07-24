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

# Sort order tests

@test "sorts source before its test when both are dirty" {
  mkdir -p "$BATS_GIT_DIR/src/__tests__"
  echo "x" > "$BATS_GIT_DIR/src/app.js"
  echo "x" > "$BATS_GIT_DIR/src/__tests__/app.test.js"
  bats_git add .
  bats_git commit --quiet -m "add files"
  echo "modified" > "$BATS_GIT_DIR/src/app.js"
  echo "modified" > "$BATS_GIT_DIR/src/__tests__/app.test.js"

  filetypes-load-definitions() { :; }
  filetypes-group() { REPLY="script"; }
  test-path() {
    case "${1:t}" in
      app.js) echo "${1:h}/__tests__/app.test.js" ;;
      *) return 1 ;;
    esac
  }
  nvim() {
    shift
    printf '%s\n' "$@"
  }
  bats_mock filetypes-load-definitions filetypes-group test-path nvim

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-edit"
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == *"/src/app.js" ]]
  [[ "${lines[1]}" == *"/src/__tests__/app.test.js" ]]
}

@test "sorts multiple source-test pairs adjacently" {
  mkdir -p "$BATS_GIT_DIR/src/__tests__"
  echo "x" > "$BATS_GIT_DIR/src/app.js"
  echo "x" > "$BATS_GIT_DIR/src/__tests__/app.test.js"
  echo "x" > "$BATS_GIT_DIR/src/utils.js"
  echo "x" > "$BATS_GIT_DIR/src/__tests__/utils.test.js"
  bats_git add .
  bats_git commit --quiet -m "add files"
  echo "modified" > "$BATS_GIT_DIR/src/app.js"
  echo "modified" > "$BATS_GIT_DIR/src/__tests__/app.test.js"
  echo "modified" > "$BATS_GIT_DIR/src/utils.js"
  echo "modified" > "$BATS_GIT_DIR/src/__tests__/utils.test.js"

  filetypes-load-definitions() { :; }
  filetypes-group() { REPLY="script"; }
  test-path() {
    case "${1:t}" in
      app.js) echo "${1:h}/__tests__/app.test.js" ;;
      utils.js) echo "${1:h}/__tests__/utils.test.js" ;;
      *) return 1 ;;
    esac
  }
  nvim() {
    shift
    printf '%s\n' "$@"
  }
  bats_mock filetypes-load-definitions filetypes-group test-path nvim

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-edit"
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == *"/src/app.js" ]]
  [[ "${lines[1]}" == *"/src/__tests__/app.test.js" ]]
  [[ "${lines[2]}" == *"/src/utils.js" ]]
  [[ "${lines[3]}" == *"/src/__tests__/utils.test.js" ]]
}

@test "keeps test file when only test is dirty" {
  mkdir -p "$BATS_GIT_DIR/src/__tests__"
  echo "x" > "$BATS_GIT_DIR/src/app.js"
  echo "x" > "$BATS_GIT_DIR/src/__tests__/app.test.js"
  bats_git add .
  bats_git commit --quiet -m "add files"
  echo "modified" > "$BATS_GIT_DIR/src/__tests__/app.test.js"

  filetypes-load-definitions() { :; }
  filetypes-group() { REPLY="script"; }
  test-path() { return 1; }
  nvim() {
    shift
    printf '%s\n' "$@"
  }
  bats_mock filetypes-load-definitions filetypes-group test-path nvim

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-edit"
  [ "$status" -eq 0 ]
  [[ "$output" == *"app.test.js"* ]]
}

@test "keeps source file when only source is dirty" {
  mkdir -p "$BATS_GIT_DIR/src/__tests__"
  echo "x" > "$BATS_GIT_DIR/src/app.js"
  echo "x" > "$BATS_GIT_DIR/src/__tests__/app.test.js"
  bats_git add .
  bats_git commit --quiet -m "add files"
  echo "modified" > "$BATS_GIT_DIR/src/app.js"

  filetypes-load-definitions() { :; }
  filetypes-group() { REPLY="script"; }
  test-path() {
    case "${1:t}" in
      app.js) echo "${1:h}/__tests__/app.test.js" ;;
      *) return 1 ;;
    esac
  }
  nvim() {
    shift
    printf '%s\n' "$@"
  }
  bats_mock filetypes-load-definitions filetypes-group test-path nvim

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-edit"
  [ "$status" -eq 0 ]
  [[ "$output" == *"app.js"* ]]
}

@test "keeps file at natural position when no test relationship" {
  echo "modified" > "$BATS_GIT_DIR/file.txt"

  filetypes-load-definitions() { :; }
  filetypes-group() { REPLY="text"; }
  test-path() { return 1; }
  nvim() {
    shift
    printf '%s\n' "$@"
  }
  bats_mock filetypes-load-definitions filetypes-group test-path nvim

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-edit"
  [ "$status" -eq 0 ]
  [[ "$output" == *"file.txt"* ]]
}

@test "sorts paired files adjacent, unpaired at natural position" {
  mkdir -p "$BATS_GIT_DIR/src/__tests__"
  echo "x" > "$BATS_GIT_DIR/config.txt"
  echo "x" > "$BATS_GIT_DIR/src/app.js"
  echo "x" > "$BATS_GIT_DIR/src/__tests__/app.test.js"
  echo "x" > "$BATS_GIT_DIR/src/utils.js"
  bats_git add .
  bats_git commit --quiet -m "add files"
  echo "modified" > "$BATS_GIT_DIR/config.txt"
  echo "modified" > "$BATS_GIT_DIR/src/app.js"
  echo "modified" > "$BATS_GIT_DIR/src/__tests__/app.test.js"
  echo "modified" > "$BATS_GIT_DIR/src/utils.js"

  filetypes-load-definitions() { :; }
  filetypes-group() { REPLY="script"; }
  test-path() {
    case "${1:t}" in
      app.js) echo "${1:h}/__tests__/app.test.js" ;;
      utils.js) echo "${1:h}/__tests__/utils.test.js" ;;
      *) return 1 ;;
    esac
  }
  nvim() {
    shift
    printf '%s\n' "$@"
  }
  bats_mock filetypes-load-definitions filetypes-group test-path nvim

  bats_run_zsh "cd $BATS_GIT_DIR && git-file-edit"
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == *"/config.txt" ]]
  [[ "${lines[1]}" == *"/src/app.js" ]]
  [[ "${lines[2]}" == *"/src/__tests__/app.test.js" ]]
  [[ "${lines[3]}" == *"/src/utils.js" ]]
}
