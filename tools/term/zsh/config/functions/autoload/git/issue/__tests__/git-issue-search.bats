bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # gh records its arguments and each call, and prints the content of gh-response
  git-directory-is-github() { return 0; }
  gh() {
    echo "$*" > "$BATS_TMP_DIR/gh-args"
    echo "call" >> "$BATS_TMP_DIR/gh-calls"
    cat "$BATS_TMP_DIR/gh-response"
  }
  bats_mock git-directory-is-github gh

  echo '[]' > "$BATS_TMP_DIR/gh-response"
}

# Content of gh-args, the arguments of the last gh call
gh_args() {
  cat "$BATS_TMP_DIR/gh-args"
}

# -- Filters --

@test "passes --state open to gh by default" {
  bats_run_zsh "git-issue-search"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == "issue list"*"--state open"* ]]
}

@test "passes the given state to gh" {
  bats_run_zsh "git-issue-search --state closed"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == *"--state closed"* ]]
}

@test "passes the author, the label and the limit to gh" {
  bats_run_zsh "git-issue-search --author renovate --label bug --limit 5"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == *"--author renovate"* ]]
  [[ "$(gh_args)" == *"--label bug"* ]]
  [[ "$(gh_args)" == *"--limit 5"* ]]
}

@test "passes --limit 25 to gh by default" {
  bats_run_zsh "git-issue-search"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == *"--limit 25"* ]]
}

@test "turns --date-min and --date-max into a created-date range" {
  bats_run_zsh "git-issue-search --date-min 2026-01-01T10:00:00Z --date-max 2026-02-01T10:00:00Z"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == *"created:>=2026-01-01T10:00:00Z"* ]]
  [[ "$(gh_args)" == *"created:<=2026-02-01T10:00:00Z"* ]]
}

@test "treats a date without a time as midnight UTC" {
  bats_run_zsh "git-issue-search --date-min 2026-01-01 --date-max 2026-02-01"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == *"created:>=2026-01-01T00:00:00Z"* ]]
  [[ "$(gh_args)" == *"created:<=2026-02-01T00:00:00Z"* ]]
}

@test "passes --repo to gh" {
  bats_run_zsh "git-issue-search --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == *"--repo pixelastic/imoen"* ]]
}

@test "passes the positional query as a search" {
  bats_run_zsh "git-issue-search 'login bug'"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == *"--search login bug"* ]]
}

@test "keeps the query and the dates in one search" {
  bats_run_zsh "git-issue-search 'login bug' --date-min 2026-01-01"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == *"--search login bug created:>=2026-01-01T00:00:00Z"* ]]
}

# -- Output --

@test "prints a JSON array with id, title, state, date, author, url, labels and body" {
  cat > "$BATS_TMP_DIR/gh-response" <<'JSON'
[{"number":12,"title":"Login fails","state":"OPEN","createdAt":"2026-01-05T09:30:00Z","author":{"login":"pixelastic","is_bot":false},"url":"https://github.com/pixelastic/imoen/issues/12","labels":[],"body":"It fails."}]
JSON
  bats_run_zsh "git-issue-search"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output '.[0]' <<< "$output")" == '{"id":12,"title":"Login fails","state":"open","date":"2026-01-05T09:30:00Z","author":"pixelastic","url":"https://github.com/pixelastic/imoen/issues/12","labels":[],"body":"It fails."}' ]]
}

@test "prints the label names as a list" {
  cat > "$BATS_TMP_DIR/gh-response" <<'JSON'
[{"number":12,"title":"Login fails","state":"CLOSED","createdAt":"2026-01-05T09:30:00Z","author":{"login":"pixelastic"},"url":"u","labels":[{"id":"1","name":"bug","color":"d73a4a"},{"id":"2","name":"help wanted","color":"008672"}],"body":""}]
JSON
  bats_run_zsh "git-issue-search"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output '.[0].labels' <<< "$output")" == '["bug","help wanted"]' ]]
}

@test "prints [] when nothing matches" {
  bats_run_zsh "git-issue-search"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "[]" ]]
}

@test "makes one gh call" {
  bats_run_zsh "git-issue-search 'login bug' --author renovate --date-min 2026-01-01 --repo pixelastic/imoen"
  [[ "$(wc --lines < "$BATS_TMP_DIR/gh-calls")" -eq 1 ]]
}

# -- Guards --

@test "fails outside a GitHub repo without --repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "git-issue-search"
  [[ "$status" -ne 0 ]]
  [[ ! -f "$BATS_TMP_DIR/gh-calls" ]]
}

@test "does not need a GitHub repo with --repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "git-issue-search --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
}
