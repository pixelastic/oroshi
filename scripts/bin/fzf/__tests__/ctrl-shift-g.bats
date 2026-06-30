bats_load_library 'helper'

setup() {
  bats_disable_worktree_aware
}

# fzf-postprocess

@test "fzf-postprocess: extracts file:line from match line" {
  bats_run_zsh "printf '/tmp/project/app.js▮42▮  content\n' | ctrl-shift-g --postprocess"
  [ "$status" -eq 0 ]
  [ "$output" = "/tmp/project/app.js:42" ]
}

@test "fzf-postprocess: outputs nothing on empty stdin" {
  bats_run_zsh "printf '' | ctrl-shift-g --postprocess"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
