bats_load_library 'helper'

setup() {
  bats_tmp_dir
  printf ': 1680000001:0;ls\n: 1680000002:0;echo hello\n: 1680000003:0;git status\n' > "$BATS_TMP_DIR/histfile"
  bats_mock_env "HISTFILE" "$BATS_TMP_DIR/histfile"
}

# fzf-source

@test "fzf-source: outputs one entry per line" {
  bats_run_zsh "ctrl-r --source"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 3 ]
}

@test "fzf-source: strips ZSH extended history timestamp prefix" {
  bats_run_zsh "ctrl-r --source"
  [ "$status" -eq 0 ]
  [[ "$output" == *"git status"* ]]
  [[ "$output" != *": 168"* ]]
}

@test "fzf-source: does not output empty lines" {
  printf ': 1680000001:0;ls\n\n: 1680000002:0;echo hello\n' > "$BATS_TMP_DIR/histfile"
  bats_run_zsh "ctrl-r --source"
  [ "$status" -eq 0 ]
  local line
  for line in "${lines[@]}"; do
    [ -n "$line" ]
  done
}

# fzf-postprocess

@test "fzf-postprocess: outputs command from plain stdin" {
  bats_run_zsh "echo 'git status' | ctrl-r --postprocess"
  [ "$output" = "git status" ]
}

@test "fzf-postprocess: strips ZSH extended history prefix from stdin" {
  bats_run_zsh "echo ': 1680000001:0;git status' | ctrl-r --postprocess"
  [ "$output" = "git status" ]
}

@test "fzf-postprocess: outputs nothing on empty stdin" {
  bats_run_zsh "printf '' | ctrl-r --postprocess"
  [ "$output" = "" ]
}
