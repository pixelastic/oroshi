bats_load_library 'helper'

setup() {
  bats_tmp_dir

  complete-helpers() { printf 'git-branch-list\njson-lint\n'; }
  helper-documentation() { printf 'Lint a JSON file\n\nUsage: json-lint <file>\n'; }
  bats_mock complete-helpers helper-documentation
}

# fzf-source

@test "--source: prints the plain name, then the display name, per helper" {
  bats_run_zsh "fzf-helpers --source"
  [[ "$status" -eq 0 ]]
  local stripped="$(bats_strip_ansi "$output")"
  [[ "$stripped" = $'git-branch-list▮git-branch-list\njson-lint▮json-lint' ]]
}

@test "--source: colors the display name" {
  bats_run_zsh "fzf-helpers --source"
  [[ "$status" -eq 0 ]]
  local displayName="${lines[0]#*▮}"
  [[ "$displayName" == *$'\e['* ]]
}

@test "--source: leaves the plain name uncolored" {
  bats_run_zsh "fzf-helpers --source"
  [[ "$status" -eq 0 ]]
  local plainName="${lines[0]%%▮*}"
  [[ "$plainName" = "git-branch-list" ]]
}

# fzf-options

@test "--options: includes a prompt" {
  bats_run_zsh "fzf-helpers --options"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"--prompt="* ]]
}

@test "--options: displays only the colored name" {
  bats_run_zsh "fzf-helpers --options"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"--delimiter=▮"* ]]
  [[ "$output" == *"--with-nth=2"* ]]
}

@test "--options: includes a preview that runs on the plain name" {
  bats_run_zsh "fzf-helpers --options"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"--preview=bin-zsh fzf-helpers --preview {1}"* ]]
}

@test "--options: keeps multi-selection enabled" {
  bats_run_zsh "fzf-helpers --options"
  [[ "$status" -eq 0 ]]
  [[ "$output" != *"--no-multi"* ]]
}

# fzf-preview

@test "--preview: prefixes each documentation line with a hash" {
  bats_run_zsh "fzf-helpers --preview json-lint"
  [[ "$status" -eq 0 ]]
  local stripped="$(bats_strip_ansi "$output")"
  [[ "$stripped" = $'# Lint a JSON file\n#\n# Usage: json-lint <file>' ]]
}

@test "--preview: colors the whole line, not only the hash" {
  bats_run_zsh "fzf-helpers --preview json-lint"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == $'\e['*"# Lint a JSON file"$'\e[0m' ]]
}

# fzf-postprocess

@test "--postprocess: prints the selected plain names, one per line" {
  bats_run_zsh "printf 'git-branch-list▮colored1\njson-lint▮colored2\n' | fzf-helpers --postprocess"
  [[ "$status" -eq 0 ]]
  [[ "$output" = $'git-branch-list\njson-lint' ]]
}
