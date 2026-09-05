bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "regular repo: returns project path" {
  context-raw() { REPLY="myproject▮▮/repos/myproject"; }
  bats_mock context-raw
  bats_run_zsh "context-root /repos/myproject/src"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "/repos/myproject" ]]
}

@test "worktree: returns worktree root" {
  context-raw() { REPLY="myproject▮feat/x▮/worktrees/myproject--feat_x"; }
  bats_mock context-raw
  bats_run_zsh "context-root /worktrees/myproject--feat_x/src"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "/worktrees/myproject--feat_x" ]]
}

@test "submodule-in-worktree: returns superproject worktree root" {
  context-raw() { REPLY="oroshi▮announce-skill▮/worktrees/oroshi--announce-skill"; }
  bats_mock context-raw
  bats_run_zsh "context-root /worktrees/oroshi--announce-skill/private/config"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "/worktrees/oroshi--announce-skill" ]]
}

@test "outside known project: returns empty" {
  context-raw() { true; }
  bats_mock context-raw
  bats_run_zsh "context-root /tmp/random"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

@test "--reply: writes to REPLY instead of stdout" {
  context-raw() { REPLY="myproject▮▮/repos/myproject"; }
  bats_mock context-raw
  bats_run_zsh "context-root --reply /repos/myproject/src && echo \$REPLY"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "/repos/myproject" ]]
}
