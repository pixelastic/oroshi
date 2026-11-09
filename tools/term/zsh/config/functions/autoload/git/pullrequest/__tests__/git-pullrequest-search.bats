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

# Write a gh response holding one pull request with the given state, draft
# flag and status check rollup
# Usage: gh_response MERGED false '[{"state":"SUCCESS"}]'
gh_response() {
  local state="$1"
  local isDraft="$2"
  local rollup="$3"
  cat > "$BATS_TMP_DIR/gh-response" <<JSON
[{"number":27,"title":"Add search","state":"$state","isDraft":$isDraft,"createdAt":"2026-01-05T09:30:00Z","author":{"login":"pixelastic"},"url":"u","labels":[],"body":"","headRefName":"feature","baseRefName":"main","statusCheckRollup":$rollup}]
JSON
}

# -- Filters --

@test "passes --state open to gh by default" {
  bats_run_zsh "git-pullrequest-search"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == "pr list"*"--state open"* ]]
  [[ "$(gh_args)" != *"--draft"* ]]
}

@test "excludes drafts from open pull requests" {
  bats_run_zsh "git-pullrequest-search 'login bug'"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == *"--search login bug draft:false"* ]]
}

@test "passes --state merged to gh" {
  bats_run_zsh "git-pullrequest-search --state merged"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == *"--state merged"* ]]
}

@test "maps --state draft to open pull requests with --draft" {
  bats_run_zsh "git-pullrequest-search --state draft"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == *"--state open"* ]]
  [[ "$(gh_args)" == *"--draft"* ]]
}

@test "passes the author, the label and the limit to gh" {
  bats_run_zsh "git-pullrequest-search --author renovate --label bug --limit 5"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == *"--author renovate"* ]]
  [[ "$(gh_args)" == *"--label bug"* ]]
  [[ "$(gh_args)" == *"--limit 5"* ]]
}

@test "passes --limit 25 to gh by default" {
  bats_run_zsh "git-pullrequest-search"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == *"--limit 25"* ]]
}

@test "turns --date-min and --date-max into a created-date range" {
  bats_run_zsh "git-pullrequest-search --date-min 2026-01-01 --date-max 2026-02-01T10:00:00Z"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == *"created:>=2026-01-01T00:00:00Z"* ]]
  [[ "$(gh_args)" == *"created:<=2026-02-01T10:00:00Z"* ]]
}

@test "passes --repo to gh" {
  bats_run_zsh "git-pullrequest-search --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == *"--repo pixelastic/imoen"* ]]
}

@test "keeps the query and the dates in one search" {
  bats_run_zsh "git-pullrequest-search 'login bug' --date-min 2026-01-01"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_args)" == *"--search login bug draft:false created:>=2026-01-01T00:00:00Z"* ]]
}

# -- Output --

@test "prints the documented fields, including head, base and checks" {
  gh_response OPEN false '[{"__typename":"CheckRun","status":"COMPLETED","conclusion":"SUCCESS"}]'
  bats_run_zsh "git-pullrequest-search"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output '.[0]' <<< "$output")" == '{"number":27,"title":"Add search","state":"open","date":"2026-01-05T09:30:00Z","author":"pixelastic","url":"u","labels":[],"body":"","head":"feature","base":"main","checks":"success"}' ]]
}

@test "asks gh for no comments, commits or files" {
  bats_run_zsh "git-pullrequest-search"
  [[ "$(gh_args)" != *"comments"* ]]
  [[ "$(gh_args)" != *"commits"* ]]
  [[ "$(gh_args)" != *"files"* ]]
}

@test "prints the label names as a list" {
  gh_response OPEN false '[]'
  sed --in-place 's/"labels":\[\]/"labels":[{"id":"1","name":"bug"},{"id":"2","name":"help wanted"}]/' "$BATS_TMP_DIR/gh-response"
  bats_run_zsh "git-pullrequest-search"
  [[ "$(jq --compact-output '.[0].labels' <<< "$output")" == '["bug","help wanted"]' ]]
}

@test "reports draft for a draft pull request" {
  gh_response OPEN true '[]'
  bats_run_zsh "git-pullrequest-search"
  [[ "$(jq --raw-output '.[0].state' <<< "$output")" == "draft" ]]
}

@test "reports merged for a merged pull request" {
  gh_response MERGED false '[]'
  bats_run_zsh "git-pullrequest-search --state merged"
  [[ "$(jq --raw-output '.[0].state' <<< "$output")" == "merged" ]]
}

@test "reports closed for a closed pull request" {
  gh_response CLOSED false '[]'
  bats_run_zsh "git-pullrequest-search --state closed"
  [[ "$(jq --raw-output '.[0].state' <<< "$output")" == "closed" ]]
}

@test "rolls the checks up to success" {
  gh_response OPEN false '[{"status":"COMPLETED","conclusion":"SUCCESS"},{"state":"SUCCESS"}]'
  bats_run_zsh "git-pullrequest-search"
  [[ "$(jq --raw-output '.[0].checks' <<< "$output")" == "success" ]]
}

@test "rolls the checks up to failure when one fails" {
  gh_response OPEN false '[{"status":"COMPLETED","conclusion":"SUCCESS"},{"status":"COMPLETED","conclusion":"FAILURE"},{"status":"IN_PROGRESS","conclusion":""}]'
  bats_run_zsh "git-pullrequest-search"
  [[ "$(jq --raw-output '.[0].checks' <<< "$output")" == "failure" ]]
}

@test "rolls a failed status context up to failure" {
  gh_response OPEN false '[{"state":"ERROR"}]'
  bats_run_zsh "git-pullrequest-search"
  [[ "$(jq --raw-output '.[0].checks' <<< "$output")" == "failure" ]]
}

@test "rolls the checks up to pending when one is not finished" {
  gh_response OPEN false '[{"status":"COMPLETED","conclusion":"SUCCESS"},{"status":"IN_PROGRESS","conclusion":""}]'
  bats_run_zsh "git-pullrequest-search"
  [[ "$(jq --raw-output '.[0].checks' <<< "$output")" == "pending" ]]
}

@test "rolls a pending status context up to pending" {
  gh_response OPEN false '[{"state":"PENDING"}]'
  bats_run_zsh "git-pullrequest-search"
  [[ "$(jq --raw-output '.[0].checks' <<< "$output")" == "pending" ]]
}

@test "prints an empty checks when there is no check" {
  gh_response OPEN false '[]'
  bats_run_zsh "git-pullrequest-search"
  [[ "$(jq --raw-output '.[0].checks' <<< "$output")" == "" ]]
}

@test "prints [] when nothing matches" {
  bats_run_zsh "git-pullrequest-search"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "[]" ]]
}

@test "makes one gh call" {
  bats_run_zsh "git-pullrequest-search 'login bug' --author renovate --state draft --repo pixelastic/imoen"
  [[ "$(wc --lines < "$BATS_TMP_DIR/gh-calls")" -eq 1 ]]
}

# -- Guards --

@test "fails outside a GitHub repo without --repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "git-pullrequest-search"
  [[ "$status" -ne 0 ]]
  [[ ! -f "$BATS_TMP_DIR/gh-calls" ]]
}

@test "does not need a GitHub repo with --repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "git-pullrequest-search --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
}
