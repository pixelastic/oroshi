bats_load_library 'helper'

setup() {
  CURRENT="$BATS_TEST_DIRNAME/../ctrl-r"
  bats_tmp_dir
  printf ': 1680000001:0;ls\n: 1680000002:0;echo hello\n: 1680000003:0;git status\n' > "$BATS_TMP_DIR/histfile"
  export HISTFILE="$BATS_TMP_DIR/histfile"
}

# fzf-source

@test "fzf-source: outputs one entry per line" {
  run "$CURRENT" --source
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 3 ]
}

@test "fzf-source: strips ZSH extended history timestamp prefix" {
  run "$CURRENT" --source
  [ "$status" -eq 0 ]
  [[ "$output" == *"git status"* ]]
  [[ "$output" != *": 168"* ]]
}

@test "fzf-source: does not output empty lines" {
  printf ': 1680000001:0;ls\n\n: 1680000002:0;echo hello\n' > "$BATS_TMP_DIR/histfile"
  run "$CURRENT" --source
  [ "$status" -eq 0 ]
  local line
  for line in "${lines[@]}"; do
    [ -n "$line" ]
  done
}

# fzf-postprocess

@test "fzf-postprocess: outputs command from plain stdin" {
  local result="$(echo 'git status' | "$CURRENT" --postprocess)"
  [ "$result" = "git status" ]
}

@test "fzf-postprocess: strips ZSH extended history prefix from stdin" {
  local result="$(echo ': 1680000001:0;git status' | "$CURRENT" --postprocess)"
  [ "$result" = "git status" ]
}

@test "fzf-postprocess: outputs nothing on empty stdin" {
  local result="$(printf '' | "$CURRENT" --postprocess)"
  [ "$result" = "" ]
}
