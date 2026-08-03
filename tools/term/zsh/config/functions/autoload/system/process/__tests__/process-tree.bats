bats_load_library 'helper'

setup() {
  # Mock colors/icons loaders to set ICONS[process-current]
  colors-load-definitions() { :; }
  icons-load-definitions() {
    typeset -gA ICONS
    ICONS[process-current]="PTR"
  }

  # Mock colorize: returns "[color:text]" for assertion
  colorize() { echo -n "[$2:$1]"; }

  # Default: 3-process chain (self first, ancestors after)
  process-tree-raw() {
    echo "100▮zsh"
    echo "50▮bash"
    echo "2▮init-helper"
  }

  bats_mock colors-load-definitions icons-load-definitions colorize process-tree-raw
}

@test "first line is the oldest ancestor, no connector" {
  bats_run_zsh "process-tree 100"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == *"init-helper"* ]]
  [[ "${lines[0]}" == *"2"* ]]
  [[ "${lines[0]}" != *"└──"* ]]
}

@test "second line starts with └──" {
  bats_run_zsh "process-tree 100"
  [[ "$status" -eq 0 ]]
  [[ "${lines[1]}" == "└── "* ]]
}

@test "third line starts with 4-space indent then └──" {
  bats_run_zsh "process-tree 100"
  [[ "$status" -eq 0 ]]
  [[ "${lines[2]}" == "    └── "* ]]
}

@test "last line is the current process with green arrow" {
  bats_run_zsh "process-tree 100"
  [[ "$status" -eq 0 ]]
  local lastLine="${lines[2]}"
  [[ "$lastLine" == *"[executable:zsh]"* ]]
  [[ "$lastLine" == *"[number:100]"* ]]
  # Arrow comes after PID
  [[ "$lastLine" == *"[number:100])"*"[pointer:PTR]"* ]]
}

@test "colorize called with executable color for name" {
  bats_run_zsh "process-tree 100"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"[executable:zsh]"* ]]
}

@test "colorize called with number color for PID" {
  bats_run_zsh "process-tree 100"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"[number:100]"* ]]
}

@test "defaults to current process when called without arguments" {
  bats_run_zsh "process-tree"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"[executable:zsh]"* ]]
}

@test "returns 0 with no output when process-tree-raw fails" {
  process-tree-raw() { return 1; }
  bats_mock process-tree-raw

  bats_run_zsh "process-tree 100"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}
