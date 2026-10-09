bats_load_library 'helper'

setup() {
  bats_tmp_dir

  complete-skills-allowlist-add() { printf 'jq\nrg\n'; }
  bats_mock complete-skills-allowlist-add
}

# fzf-source

@test "--source: prints the helper output" {
  bats_run_zsh "fzf-skills-allowlist-add --source"
  [[ "$status" -eq 0 ]]
  [[ "$output" = $'jq\nrg' ]]
}

# fzf-options

@test "--options: includes a prompt" {
  bats_run_zsh "fzf-skills-allowlist-add --options"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"--prompt="* ]]
}

@test "--options: includes the ctrl-b preview command" {
  bats_run_zsh "fzf-skills-allowlist-add --options"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"--preview=bin-zsh ctrl-b --preview {}"* ]]
}

# fzf-postprocess

@test "--postprocess: prints the selected command names" {
  bats_run_zsh "printf 'jq\nrg\n' | fzf-skills-allowlist-add --postprocess"
  [[ "$status" -eq 0 ]]
  [[ "$output" = $'jq\nrg' ]]
}
