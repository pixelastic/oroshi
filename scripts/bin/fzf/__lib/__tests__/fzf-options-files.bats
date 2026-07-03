bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source '${BATS_TEST_DIRNAME}/../fzf-options-files.zsh'"

  colors-load-definitions() {
    typeset -gA COLORS
    COLORS[file]=42
    COLORS[directory]=100
  }
  context-badge() { echo ""; }
  simplify-path() { echo "$1"; }
  colorize() { echo "$1"; }
  bats_mock colors-load-definitions context-badge simplify-path colorize
}

@test "emits --with-nth=2" {
  bats_run_zsh "${sourcePrefix}; fzf-options-files ctrl-p /tmp/search"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--with-nth=2"* ]]
}

@test "emits --scheme=path and --tiebreak=pathname,chunk" {
  bats_run_zsh "${sourcePrefix}; fzf-options-files ctrl-p /tmp/search"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--scheme=path"* ]]
  [[ "$output" == *"--tiebreak=pathname,chunk"* ]]
}

@test "preview uses scriptName arg" {
  bats_run_zsh "${sourcePrefix}; fzf-options-files ctrl-p /tmp/search"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--preview=ctrl-p --preview {1}"* ]]
}

@test "preview changes with different scriptName" {
  bats_run_zsh "${sourcePrefix}; fzf-options-files ctrl-shift-p /tmp/search"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--preview=ctrl-shift-p --preview {1}"* ]]
}

@test "emits --prompt option" {
  bats_run_zsh "${sourcePrefix}; fzf-options-files ctrl-p /tmp/search"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--prompt="* ]]
}

@test "color options use COLORS[file]" {
  bats_run_zsh "${sourcePrefix}; fzf-options-files ctrl-p /tmp/search"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--color=query:42:regular"* ]]
  [[ "$output" == *"--color=info:42"* ]]
  [[ "$output" == *"--color=separator:42"* ]]
}

@test "includes base options from fzf-options-base" {
  bats_run_zsh "${sourcePrefix}; fzf-options-files ctrl-p /tmp/search"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--delimiter=▮"* ]]
}
