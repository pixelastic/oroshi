bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # gh records its arguments and prints the content of gh-response
  git-directory-is-github() { return 0; }
  gh() {
    echo "$*" >> "$BATS_TMP_DIR/gh-calls"
    cat "$BATS_TMP_DIR/gh-response"
  }
  bats_mock git-directory-is-github gh

  cat > "$BATS_TMP_DIR/gh-response" <<'JSON'
[
  {"id": "LA_kwDOA", "name": "bug", "color": "d73a4a", "description": "Something is broken"},
  {"id": "LA_kwDOB", "name": "help wanted", "color": "008672", "description": ""}
]
JSON
}

@test "prints one label per line" {
  bats_run_zsh "git-label-list-raw"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]
  [[ "${lines[0]}" == "bug▮"* ]]
  [[ "${lines[1]}" == "help wanted▮"* ]]
}

@test "prints the name, color and description" {
  bats_run_zsh "git-label-list-raw"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == "bug▮#d73a4a▮Something is broken" ]]
}

@test "prints an empty description field when a label has none" {
  bats_run_zsh "git-label-list-raw"
  [[ "$status" -eq 0 ]]
  [[ "${lines[1]}" == "help wanted▮#008672▮" ]]
}

@test "does not print the internal id" {
  bats_run_zsh "git-label-list-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" != *"LA_kw"* ]]
}

@test "prints nothing when the repo has no label" {
  echo '[]' > "$BATS_TMP_DIR/gh-response"

  bats_run_zsh "git-label-list-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "targets another repo with --repo" {
  bats_run_zsh "git-label-list-raw --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/gh-calls")" == *"--repo pixelastic/imoen"* ]]
}

@test "stops outside a GitHub repo without --repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "git-label-list-raw"
  [[ "$status" -ne 0 ]]
  [[ ! -e "$BATS_TMP_DIR/gh-calls" ]]
}

@test "lists another repo outside a GitHub repo with --repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "git-label-list-raw --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]
}
