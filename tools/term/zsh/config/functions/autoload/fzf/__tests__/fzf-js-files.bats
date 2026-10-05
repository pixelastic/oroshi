bats_load_library 'helper'

setup() {
  bats_tmp_dir

  mkdir -p "$BATS_TMP_DIR/src" "$BATS_TMP_DIR/__tests__"
  touch "$BATS_TMP_DIR/src/main.js" "$BATS_TMP_DIR/__tests__/my-test.js"

  # Mock git-directory-root to return a known path
  git-directory-root() { echo "$BATS_TMP_DIR"; }
  fd() { printf 'src/main.js\n'; }
  bats_mock git-directory-root fd
}

# fzf-source

@test "--source: first field is the absolute filepath" {
  bats_run_zsh "fzf-js-files --source"
  [[ "$status" -eq 0 ]]
  local firstField="${output%%▮*}"
  [[ "$firstField" = "$BATS_TMP_DIR/src/main.js" ]]
}

@test "--source: second field is ANSI-colored" {
  bats_run_zsh "fzf-js-files --source"
  [[ "$status" -eq 0 ]]
  local secondField="${output##*▮}"
  [[ "$secondField" == *$'\e['* ]]
}

@test "--source: outputs nothing when no JS files exist" {
  fd() { echo ""; }
  bats_mock fd
  bats_run_zsh "fzf-js-files --source"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}
