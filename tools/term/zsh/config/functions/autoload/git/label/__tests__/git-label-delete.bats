bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # gh records the arguments of each call. `gh label delete` fails when the
  # gh-missing file exists, like a label that does not exist
  git-directory-is-github() { return 0; }
  gh() {
    echo "$*" >> "$BATS_TMP_DIR/gh-args"
    [[ -f "$BATS_TMP_DIR/gh-missing" ]] && return 1
    return 0
  }
  bats_mock git-directory-is-github gh
}

# Content of gh-args, one line per gh call
gh_args() {
  cat "$BATS_TMP_DIR/gh-args"
}

@test "deletes the label by name" {
  bats_run_zsh "git-label-delete 'help wanted'"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == "label delete help wanted --yes" ]]
}

@test "prints the deleted name" {
  bats_run_zsh "git-label-delete bug"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output <<< "$output")" == '{"name":"bug"}' ]]
}

@test "targets another repo with --repo" {
  bats_run_zsh "git-label-delete bug --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == "label delete bug --yes --repo pixelastic/imoen" ]]
}

@test "fails when the label does not exist" {
  touch "$BATS_TMP_DIR/gh-missing"

  bats_run_zsh "git-label-delete missing"
  [[ "$status" -ne 0 ]]
  [[ "$output" == "" ]]
}

@test "fails outside a GitHub repo without --repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "git-label-delete bug"
  [[ "$status" -ne 0 ]]
  [[ ! -f "$BATS_TMP_DIR/gh-args" ]]
}

@test "does not need a GitHub repo with --repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "git-label-delete bug --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
}
