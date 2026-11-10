bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # gh records the arguments of each call, and prints the content of the
  # response file matching its subcommand (view, checks or diff)
  git-directory-is-github() { return 0; }
  gh() {
    echo "$*" >> "$BATS_TMP_DIR/gh-calls"
    cat "$BATS_TMP_DIR/gh-response-$2"
  }
  bats_mock git-directory-is-github gh

  cat > "$BATS_TMP_DIR/gh-response-view" <<'JSON'
{
  "number": 27,
  "title": "Update dependency",
  "state": "OPEN",
  "isDraft": false,
  "createdAt": "2026-01-02T03:04:05Z",
  "author": {"login": "renovate"},
  "url": "https://github.com/pixelastic/imoen/pull/27",
  "labels": [{"name": "dependencies"}, {"name": "bot"}],
  "headRefName": "renovate/dep",
  "baseRefName": "main",
  "mergeStateStatus": "CLEAN",
  "body": "Bumps dep.",
  "comments": [
    {"id": "IC_kwDOA", "url": "https://github.com/pixelastic/imoen/pull/27#issuecomment-2001", "author": {"login": "alice"}, "createdAt": "2026-01-03T00:00:00Z", "body": "Looks good."},
    {"id": "IC_kwDOB", "url": "https://github.com/pixelastic/imoen/pull/27#issuecomment-2002", "author": {"login": "bob"}, "createdAt": "2026-01-04T00:00:00Z", "body": "Merging."}
  ],
  "files": [
    {"path": "package.json", "additions": 1, "deletions": 2},
    {"path": "yarn.lock", "additions": 30, "deletions": 40}
  ],
  "commits": [
    {"oid": "0123456789abcdef0123456789abcdef01234567", "messageHeadline": "chore(deps): update dep"},
    {"oid": "fedcba9876543210fedcba9876543210fedcba98", "messageHeadline": "fix: lockfile"}
  ]
}
JSON

  cat > "$BATS_TMP_DIR/gh-response-checks" <<'JSON'
[
  {"name": "build", "state": "SUCCESS", "link": "https://ci/build", "bucket": "pass"},
  {"name": "lint", "state": "FAILURE", "link": "https://ci/lint", "bucket": "fail"}
]
JSON

  printf 'diff --git a/package.json b/package.json\n+new\n' > "$BATS_TMP_DIR/gh-response-diff"
}

# Content of gh-calls, one line per gh call
gh_calls() {
  cat "$BATS_TMP_DIR/gh-calls"
}

@test "prints the documented fields for a pull request" {
  bats_run_zsh "git-pullrequest-read 27"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output 'del(.comments, .files, .commits, .checks)' <<< "$output")" == '{"id":27,"title":"Update dependency","state":"open","date":"2026-01-02T03:04:05Z","author":"renovate","url":"https://github.com/pixelastic/imoen/pull/27","labels":["dependencies","bot"],"head":"renovate/dep","base":"main","mergeState":"clean","body":"Bumps dep."}' ]]
}

@test "prints draft as the state of a draft pull request" {
  jq '.isDraft = true' "$BATS_TMP_DIR/gh-response-view" > "$BATS_TMP_DIR/tmp"
  mv "$BATS_TMP_DIR/tmp" "$BATS_TMP_DIR/gh-response-view"

  bats_run_zsh "git-pullrequest-read 27"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --raw-output '.state' <<< "$output")" == "draft" ]]
}

@test "prints the complete body" {
  local body="$(printf 'line %s\n' {1..200})"
  jq --arg body "$body" '.body = $body' "$BATS_TMP_DIR/gh-response-view" > "$BATS_TMP_DIR/tmp"
  mv "$BATS_TMP_DIR/tmp" "$BATS_TMP_DIR/gh-response-view"

  bats_run_zsh "git-pullrequest-read 27"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --raw-output '.body' <<< "$output")" == "$body" ]]
}

@test "prints id and no number" {
  bats_run_zsh "git-pullrequest-read 27"
  [[ "$status" -eq 0 ]]
  [[ "$(jq '.id' <<< "$output")" == "27" ]]
  [[ "$(jq 'has("number")' <<< "$output")" == "false" ]]
}

@test "prints every comment with its id, author, date and body" {
  bats_run_zsh "git-pullrequest-read 27"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output '.comments' <<< "$output")" == '[{"id":2001,"author":"alice","date":"2026-01-03T00:00:00Z","body":"Looks good."},{"id":2002,"author":"bob","date":"2026-01-04T00:00:00Z","body":"Merging."}]' ]]
}

@test "prints the id of a comment as a number, never the internal identifier" {
  bats_run_zsh "git-pullrequest-read 27"
  [[ "$status" -eq 0 ]]
  [[ "$output" != *"IC_kwDO"* ]]
}

@test "prints the file paths only, without counts, by default" {
  bats_run_zsh "git-pullrequest-read 27"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output '.files' <<< "$output")" == '["package.json","yarn.lock"]' ]]
  [[ "$(jq 'has("diff")' <<< "$output")" == "false" ]]
}

@test "prints the commits with a short sha and a message" {
  bats_run_zsh "git-pullrequest-read 27"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output '.commits' <<< "$output")" == '[{"sha":"0123456","message":"chore(deps): update dep"},{"sha":"fedcba9","message":"fix: lockfile"}]' ]]
}

@test "prints the checks with name, state and link" {
  bats_run_zsh "git-pullrequest-read 27"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output '.checks' <<< "$output")" == '[{"name":"build","state":"success","link":"https://ci/build"},{"name":"lint","state":"failure","link":"https://ci/lint"}]' ]]
}

@test "prints an empty check list when there is no check" {
  # gh pr checks exits with an error and prints nothing when there is no check
  gh() {
    echo "$*" >> "$BATS_TMP_DIR/gh-calls"
    if [[ "$2" == "checks" ]]; then
      echo "no checks reported on the 'main' branch" >&2
      return 1
    fi
    cat "$BATS_TMP_DIR/gh-response-$2"
  }
  bats_mock gh

  bats_run_zsh "git-pullrequest-read 27"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output '.checks' <<< "$output")" == '[]' ]]
}

@test "prints the checks of a pull request with pending checks" {
  # gh pr checks exits with 8 when checks are pending, but still prints them
  gh() {
    echo "$*" >> "$BATS_TMP_DIR/gh-calls"
    cat "$BATS_TMP_DIR/gh-response-$2"
    [[ "$2" == "checks" ]] && return 8
    return 0
  }
  bats_mock gh

  bats_run_zsh "git-pullrequest-read 27"
  [[ "$status" -eq 0 ]]
  [[ "$(jq '.checks | length' <<< "$output")" == "2" ]]
}

@test "adds the file counts and the diff with --full" {
  bats_run_zsh "git-pullrequest-read 27 --full"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output '.files' <<< "$output")" == '[{"path":"package.json","additions":1,"deletions":2},{"path":"yarn.lock","additions":30,"deletions":40}]' ]]
  [[ "$(jq --raw-output '.diff' <<< "$output")" == "$(cat "$BATS_TMP_DIR/gh-response-diff")" ]]
}

@test "changes nothing else with --full" {
  bats_run_zsh "git-pullrequest-read 27"
  local defaultOutput="$output"
  bats_run_zsh "git-pullrequest-read 27 --full"
  [[ "$(jq --compact-output 'del(.files, .diff)' <<< "$output")" == "$(jq --compact-output 'del(.files)' <<< "$defaultOutput")" ]]
}

@test "does not call gh pr diff by default" {
  bats_run_zsh "git-pullrequest-read 27"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_calls)" != *"pr diff"* ]]
}

@test "passes the number and --repo to every gh call" {
  bats_run_zsh "git-pullrequest-read 27 --full --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
  [[ "$(gh_calls | wc -l)" -eq 3 ]]
  while read -r call; do
    [[ "$call" == "pr "*" 27 "*"--repo pixelastic/imoen"* ]]
  done < <(gh_calls)
}

@test "fails with an error for an unknown number" {
  gh() {
    echo "GraphQL: Could not resolve to a PullRequest" >&2
    return 1
  }
  bats_mock gh

  bats_run_zsh "git-pullrequest-read 999"
  [[ "$status" -ne 0 ]]
}

@test "fails outside a GitHub repo without --repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "git-pullrequest-read 27"
  [[ "$status" -ne 0 ]]
  [[ ! -f "$BATS_TMP_DIR/gh-calls" ]]
}

@test "does not need a GitHub repo with --repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "git-pullrequest-read 27 --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
}
