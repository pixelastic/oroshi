bats_load_library 'helper'

setup() {
  bats_disable_worktree_aware
}

# Status prefix mapping

@test "modified file produces output containing ~" {
  bats_run_zsh "source ${BATS_TEST_DIRNAME}/../fzf-colorize-git-status-path.zsh && fzf-colorize-git-status-path src/app.ts M && echo \$REPLY"
  [[ "$status" -eq 0 ]]
  local stripped="$(bats_strip_ansi "$output")"
  [[ "$stripped" == *"~"* ]]
}

@test "added file produces output containing +" {
  bats_run_zsh "source ${BATS_TEST_DIRNAME}/../fzf-colorize-git-status-path.zsh && fzf-colorize-git-status-path src/app.ts A && echo \$REPLY"
  [[ "$status" -eq 0 ]]
  local stripped="$(bats_strip_ansi "$output")"
  [[ "$stripped" == *"+"* ]]
}

@test "deleted file produces output containing -" {
  bats_run_zsh "source ${BATS_TEST_DIRNAME}/../fzf-colorize-git-status-path.zsh && fzf-colorize-git-status-path src/app.ts D && echo \$REPLY"
  [[ "$status" -eq 0 ]]
  local stripped="$(bats_strip_ansi "$output")"
  [[ "$stripped" == *"-"* ]]
}

# Path components

@test "output contains the filename" {
  bats_run_zsh "source ${BATS_TEST_DIRNAME}/../fzf-colorize-git-status-path.zsh && fzf-colorize-git-status-path src/app.ts M && echo \$REPLY"
  [[ "$status" -eq 0 ]]
  local stripped="$(bats_strip_ansi "$output")"
  [[ "$stripped" == *"app.ts"* ]]
}

@test "output for a nested path contains the directory component" {
  bats_run_zsh "source ${BATS_TEST_DIRNAME}/../fzf-colorize-git-status-path.zsh && fzf-colorize-git-status-path src/components/Button.tsx M && echo \$REPLY"
  [[ "$status" -eq 0 ]]
  local stripped="$(bats_strip_ansi "$output")"
  [[ "$stripped" == *"src/components/"* ]]
}

# ANSI coloring

@test "output contains ANSI escape sequences" {
  bats_run_zsh "source ${BATS_TEST_DIRNAME}/../fzf-colorize-git-status-path.zsh && fzf-colorize-git-status-path src/app.ts M && echo \$REPLY"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *$'\e['* ]]
}
