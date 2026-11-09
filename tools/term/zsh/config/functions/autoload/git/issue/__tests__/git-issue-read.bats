bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # gh records its arguments and prints the content of gh-response
  git-directory-is-github() { return 0; }
  gh() {
    echo "$*" > "$BATS_TMP_DIR/gh-args"
    cat "$BATS_TMP_DIR/gh-response"
  }
  bats_mock git-directory-is-github gh

  cat > "$BATS_TMP_DIR/gh-response" <<'JSON'
{
  "number": 42,
  "title": "Login fails",
  "state": "OPEN",
  "createdAt": "2026-01-02T03:04:05Z",
  "author": {"login": "pixelastic"},
  "url": "https://github.com/pixelastic/imoen/issues/42",
  "labels": [{"name": "bug"}, {"name": "auth"}],
  "body": "It fails.",
  "comments": [
    {"author": {"login": "alice"}, "createdAt": "2026-01-03T00:00:00Z", "body": "Confirmed."},
    {"author": {"login": "bob"}, "createdAt": "2026-01-04T00:00:00Z", "body": "Fixed in #43."}
  ]
}
JSON
}

# Content of gh-args, the arguments of the last gh call
gh_args() {
  cat "$BATS_TMP_DIR/gh-args"
}

@test "prints the documented fields for an issue" {
  bats_run_zsh "git-issue-read 42"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output 'del(.comments)' <<< "$output")" == '{"number":42,"title":"Login fails","state":"open","date":"2026-01-02T03:04:05Z","author":"pixelastic","url":"https://github.com/pixelastic/imoen/issues/42","labels":["bug","auth"],"body":"It fails."}' ]]
}

@test "prints every comment with its author, date and body" {
  bats_run_zsh "git-issue-read 42"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output '.comments' <<< "$output")" == '[{"author":"alice","date":"2026-01-03T00:00:00Z","body":"Confirmed."},{"author":"bob","date":"2026-01-04T00:00:00Z","body":"Fixed in #43."}]' ]]
}

@test "prints an empty comment list for an issue without comment" {
  jq '.comments = []' "$BATS_TMP_DIR/gh-response" > "$BATS_TMP_DIR/gh-response.tmp"
  mv "$BATS_TMP_DIR/gh-response.tmp" "$BATS_TMP_DIR/gh-response"

  bats_run_zsh "git-issue-read 42"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output '.comments' <<< "$output")" == '[]' ]]
}

@test "prints the complete body" {
  local body="$(printf 'line %s\n' {1..200})"
  jq --arg body "$body" '.body = $body' "$BATS_TMP_DIR/gh-response" > "$BATS_TMP_DIR/gh-response.tmp"
  mv "$BATS_TMP_DIR/gh-response.tmp" "$BATS_TMP_DIR/gh-response"

  bats_run_zsh "git-issue-read 42"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --raw-output '.body' <<< "$output")" == "$body" ]]
}

@test "passes the number to gh" {
  bats_run_zsh "git-issue-read 42"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == "issue view 42"* ]]
}

@test "passes --repo to gh" {
  bats_run_zsh "git-issue-read 42 --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == *"--repo pixelastic/imoen"* ]]
}

@test "fails with an error for an unknown number" {
  gh() {
    echo "GraphQL: Could not resolve to an issue" >&2
    return 1
  }
  bats_mock gh

  bats_run_zsh "git-issue-read 999"
  [[ "$status" -ne 0 ]]
}

@test "fails outside a GitHub repo without --repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "git-issue-read 42"
  [[ "$status" -ne 0 ]]
  [[ ! -f "$BATS_TMP_DIR/gh-args" ]]
}

@test "does not need a GitHub repo with --repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "git-issue-read 42 --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
}
