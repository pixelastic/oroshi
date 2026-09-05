bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "returns path relative to context root" {
  context-root() { REPLY="/my/root"; }
  bats_mock context-root
  bats_run_zsh "context-path /my/root/src/foo"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "src/foo" ]]
}

@test "at context root: returns empty" {
  context-root() { REPLY="/my/root"; }
  bats_mock context-root
  bats_run_zsh "context-path /my/root"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

@test "outside known project: returns empty" {
  context-root() { REPLY=""; }
  bats_mock context-root
  bats_run_zsh "context-path /tmp/unregistered"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

@test "submodule-in-worktree: returns path relative to superproject worktree root" {
  context-root() { REPLY="/worktrees/oroshi--announce-skill"; }
  bats_mock context-root
  bats_run_zsh "context-path /worktrees/oroshi--announce-skill/private/config"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "private/config" ]]
}

@test "--reply: writes to REPLY instead of stdout" {
  context-root() { REPLY="/my/root"; }
  bats_mock context-root
  bats_run_zsh "context-path --reply /my/root/src/foo && echo \$REPLY"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "src/foo" ]]
}
