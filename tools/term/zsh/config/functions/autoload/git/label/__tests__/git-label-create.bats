bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # gh records the arguments of each call. The label then appears in
  # git-label-list-raw, as GitHub would list it after the creation
  git-directory-is-github() { return 0; }
  gh() {
    echo "$*" >> "$BATS_TMP_DIR/gh-args"
    return 0
  }
  git-label-list-raw() {
    echo "bug▮#d73a4a▮Something is broken"
    echo "docs▮#ededed▮"
  }
  bats_mock git-directory-is-github gh git-label-list-raw
}

# Content of gh-args, one line per gh call
gh_args() {
  cat "$BATS_TMP_DIR/gh-args"
}

@test "creates a label with only a name" {
  bats_run_zsh "git-label-create docs"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == "label create docs" ]]
}

@test "passes the color and the description" {
  bats_run_zsh "git-label-create bug --color d73a4a --description 'Something is broken'"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == "label create bug --color d73a4a --description Something is broken" ]]
}

@test "prints the name, color and description" {
  bats_run_zsh "git-label-create bug --color d73a4a --description 'Something is broken'"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output <<< "$output")" == '{"name":"bug","color":"#d73a4a","description":"Something is broken"}' ]]
}

@test "prints the color GitHub picked when none is given" {
  bats_run_zsh "git-label-create docs"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output <<< "$output")" == '{"name":"docs","color":"#ededed","description":""}' ]]
}

@test "targets another repo with --repo" {
  bats_run_zsh "git-label-create docs --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == "label create docs --repo pixelastic/imoen" ]]
}

@test "fails when gh fails" {
  gh() {
    echo "label already exists" >&2
    return 1
  }
  bats_mock gh

  bats_run_zsh "git-label-create bug"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"label already exists"* ]]
}

@test "fails outside a GitHub repo without --repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "git-label-create bug"
  [[ "$status" -ne 0 ]]
  [[ ! -f "$BATS_TMP_DIR/gh-args" ]]
}

@test "does not need a GitHub repo with --repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "git-label-create bug --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
}
