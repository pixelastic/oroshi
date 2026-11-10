bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # gh records the arguments of each call and prints the REST comment
  git-directory-is-github() { return 0; }
  gh() {
    echo "$*" >> "$BATS_TMP_DIR/gh-args"
    cat <<'JSON'
{"id":987654,"user":{"login":"pixelastic"},"created_at":"2026-05-01T10:00:00Z","body":"Looks good","html_url":"https://github.com/pixelastic/imoen/issues/42#issuecomment-987654","node_id":"IC_kwDO"}
JSON
    return 0
  }
  bats_mock git-directory-is-github gh
}

# Content of gh-args, one line per gh call
gh_args() {
  cat "$BATS_TMP_DIR/gh-args"
}

@test "prints the id, author, date, body and url" {
  bats_run_zsh "git-comment-read 987654"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output <<< "$output")" == '{"id":987654,"author":"pixelastic","date":"2026-05-01T10:00:00Z","body":"Looks good","url":"https://github.com/pixelastic/imoen/issues/42#issuecomment-987654"}' ]]
}

@test "finds the comment from its id alone" {
  bats_run_zsh "git-comment-read 987654"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == 'api repos/{owner}/{repo}/issues/comments/987654' ]]
}

@test "fails when the comment does not exist" {
  gh() {
    echo "gh: Not Found (HTTP 404)" >&2
    return 1
  }
  bats_mock gh

  bats_run_zsh "git-comment-read 1"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Not Found"* ]]
}

@test "targets another repo with --repo" {
  bats_run_zsh "git-comment-read 987654 --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == 'api repos/pixelastic/imoen/issues/comments/987654' ]]
}

@test "fails when no comment id is given" {
  bats_run_zsh "git-comment-read"
  [[ "$status" -ne 0 ]]
  [[ ! -f "$BATS_TMP_DIR/gh-args" ]]
}
