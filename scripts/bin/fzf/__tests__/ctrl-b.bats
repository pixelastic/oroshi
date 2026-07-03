bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

# fzf-source

@test "fzf-source: exits with status 0" {
  bats_run_zsh "ctrl-b --source"
  [ "$status" -eq 0 ]
}

@test "fzf-source: outputs at least one command name" {
  bats_run_zsh "ctrl-b --source"
  [ "${#lines[@]}" -gt 0 ]
}

@test "fzf-source: each line contains exactly one command name" {
  bats_run_zsh "ctrl-b --source"
  local line
  for line in "${lines[@]}"; do
    [[ "$line" != *" "* ]]
  done
}

# fzf-options

@test "fzf-options: includes --prompt with Commands label" {
  bats_run_zsh "ctrl-b --options"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--prompt="* ]]
  [[ "$output" == *"Commands"* ]]
}

# fzf-postprocess

@test "fzf-postprocess: outputs command name from stdin" {
  bats_run_zsh "echo 'ls' | ctrl-b --postprocess"
  [ "$output" = "ls" ]
}

@test "fzf-postprocess: outputs nothing on empty stdin" {
  bats_run_zsh "printf '' | ctrl-b --postprocess"
  [ "$output" = "" ]
}
