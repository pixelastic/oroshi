bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # git repo with tracked and untracked files
  git -C "$BATS_TMP_DIR" init --quiet
  mkdir -p "$BATS_TMP_DIR/src/deep"
  touch "$BATS_TMP_DIR/README.md"
  touch "$BATS_TMP_DIR/src/app.js"
  touch "$BATS_TMP_DIR/src/deep/nested.js"
  touch "$BATS_TMP_DIR/ignored.log"
  printf 'ignored.log\n' > "$BATS_TMP_DIR/.gitignore"

  # cache dir for format stage tests
  CACHE_DIR="$BATS_TMP_DIR/cache"
  mkdir -p "$CACHE_DIR"
}

teardown() {
  bats_cleanup
}

# fzf-source

@test "fzf-source: outputs tracked and untracked files from git root" {
  bats_run_zsh "cd $BATS_TMP_DIR && ctrl-p --source"
  [ "$status" -eq 0 ]
  [[ "$output" == *"README.md"* ]]
  [[ "$output" == *"src/app.js"* ]]
  [[ "$output" == *"src/deep/nested.js"* ]]
}

@test "fzf-source: respects .gitignore exclusions" {
  bats_run_zsh "cd $BATS_TMP_DIR && ctrl-p --source"
  [ "$status" -eq 0 ]
  [[ "$output" != *"ignored.log"* ]]
}

@test "fzf-source: writes a cache file" {
  bats_run_zsh "cd $BATS_TMP_DIR && CTRL_P_CACHE_DIR=$CACHE_DIR ctrl-p --source"
  [ "$status" -eq 0 ]
  # Cache dir should contain a file
  local cacheFiles=("$CACHE_DIR"/*)
  [ -f "${cacheFiles[0]}" ]
}

@test "fzf-source: each line is a full relative path" {
  bats_run_zsh "cd $BATS_TMP_DIR && ctrl-p --source"
  [ "$status" -eq 0 ]
  # Lines should be plain relative paths, not truncated
  [[ "$output" == *"src/deep/nested.js"* ]]
}

# fzf-postprocess

@test "fzf-postprocess: extracts absolute path from tab-separated selection" {
  bats_run_zsh "printf '/tmp/project/src/app.js\tapp.js\n' | ctrl-p --postprocess"
  [ "$status" -eq 0 ]
  [ "$output" = "/tmp/project/src/app.js" ]
}

@test "fzf-postprocess: outputs nothing on empty stdin" {
  bats_run_zsh "printf '' | ctrl-p --postprocess"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "fzf-postprocess: handles paths with spaces" {
  bats_run_zsh "printf '/tmp/my project/my file.js\tmy file.js\n' | ctrl-p --postprocess"
  [ "$status" -eq 0 ]
  [ "$output" = "/tmp/my project/my file.js" ]
}

# format stage

@test "format: outputs two-column tab-separated lines from cache" {
  printf 'src/app.js\nsrc/deep/nested.js\n' > "$CACHE_DIR/test-cache"
  bats_run_zsh "CTRL_P_CACHE_DIR=$CACHE_DIR ctrl-p --format --cache-key test-cache --git-root $BATS_TMP_DIR --query ''"
  [ "$status" -eq 0 ]
  # Output should contain tab-separated absolute_path and display_path
  [[ "${lines[0]}" == *$'\t'* ]]
}

@test "format: shows all files when query is empty" {
  printf 'src/app.js\nsrc/deep/nested.js\n' > "$CACHE_DIR/test-cache"
  bats_run_zsh "CTRL_P_CACHE_DIR=$CACHE_DIR ctrl-p --format --cache-key test-cache --git-root $BATS_TMP_DIR --query ''"
  [ "$status" -eq 0 ]
  [[ "$output" == *"app.js"* ]]
  [[ "$output" == *"nested.js"* ]]
}

@test "format: filters files by query on full path" {
  printf 'src/app.js\nsrc/deep/nested.js\nREADME.md\n' > "$CACHE_DIR/test-cache"
  bats_run_zsh "CTRL_P_CACHE_DIR=$CACHE_DIR ctrl-p --format --cache-key test-cache --git-root $BATS_TMP_DIR --query deep"
  [ "$status" -eq 0 ]
  [[ "$output" == *"nested.js"* ]]
  [[ "$output" != *"README.md"* ]]
}

@test "format: first column is absolute path" {
  printf 'src/app.js\n' > "$CACHE_DIR/test-cache"
  bats_run_zsh "CTRL_P_CACHE_DIR=$CACHE_DIR ctrl-p --format --cache-key test-cache --git-root $BATS_TMP_DIR --query ''"
  [ "$status" -eq 0 ]
  local firstCol="${lines[0]%%$'\t'*}"
  [[ "$firstCol" == "$BATS_TMP_DIR/"* ]]
}
