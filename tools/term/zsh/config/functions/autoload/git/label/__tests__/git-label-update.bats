bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # gh records the arguments of each call. git-label-list-raw lists the label
  # as it is after the update
  git-directory-is-github() { return 0; }
  gh() {
    echo "$*" >> "$BATS_TMP_DIR/gh-args"
    return 0
  }
  git-label-list-raw() {
    echo "bug▮#d73a4a▮Something is broken"
    echo "defect▮#ededed▮Renamed"
  }
  bats_mock git-directory-is-github gh git-label-list-raw
}

# Content of gh-args, one line per gh call
gh_args() {
  cat "$BATS_TMP_DIR/gh-args"
}

@test "renames the label with --name" {
  bats_run_zsh "git-label-update bug --name defect"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == "label edit bug --name defect" ]]
}

@test "changes the color and the description" {
  bats_run_zsh "git-label-update bug --color d73a4a --description 'Something is broken'"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == "label edit bug --color d73a4a --description Something is broken" ]]
}

@test "fails when no flag is given" {
  bats_run_zsh "git-label-update bug"
  [[ "$status" -ne 0 ]]
  [[ ! -f "$BATS_TMP_DIR/gh-args" ]]
}

@test "prints the new name, color and description" {
  bats_run_zsh "git-label-update bug --name defect"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output <<< "$output")" == '{"name":"defect","color":"#ededed","description":"Renamed"}' ]]
}

@test "prints the label under its name when it is not renamed" {
  bats_run_zsh "git-label-update bug --color d73a4a"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output <<< "$output")" == '{"name":"bug","color":"#d73a4a","description":"Something is broken"}' ]]
}

@test "targets another repo with --repo" {
  bats_run_zsh "git-label-update bug --color d73a4a --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == "label edit bug --color d73a4a --repo pixelastic/imoen" ]]
}

@test "fails when the label does not exist" {
  gh() {
    echo "label not found" >&2
    return 1
  }
  bats_mock gh

  bats_run_zsh "git-label-update missing --color d73a4a"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"label not found"* ]]
}

@test "fails outside a GitHub repo without --repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "git-label-update bug --color d73a4a"
  [[ "$status" -ne 0 ]]
  [[ ! -f "$BATS_TMP_DIR/gh-args" ]]
}

@test "does not need a GitHub repo with --repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "git-label-update bug --color d73a4a --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
}
