bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
}

teardown() {
  bats_cleanup
}

@test "no remaining project-colorize calls in fzf functions" {
  local fzfDir="${OROSHI_ROOT}/tools/term/zsh/config/functions/autoload/fzf"
  run grep -r --include="*" --exclude-dir="__tests__" "project-colorize" "$fzfDir"
  [ "$status" -ne 0 ]
}
