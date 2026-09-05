bats_load_library 'helper'

setup() {
  bats_tmp_dir
  export OROSHI_TMP_FOLDER="$BATS_TMP_DIR/tmp"
  mkdir -p "$OROSHI_TMP_FOLDER/git-file-watch"

  context-slug() { echo "my-project--main"; }
  bats_mock context-slug
  bats_mock_env OROSHI_TMP_FOLDER "$OROSHI_TMP_FOLDER"

  COMMENTS_FILE="$OROSHI_TMP_FOLDER/git-file-watch/my-project--main.json"
}

# ─── SINGLE ID ──────────────────────────────────────────────────────────────

@test "removes matching comment and preserves the other 2" {
  cat > "$COMMENTS_FILE" <<'JSON'
[
  {"id":"aaa","filepath":"/src/a.go","lineNumber":1,"lineContent":"a","review":"ra","commitHash":"c1"},
  {"id":"bbb","filepath":"/src/b.go","lineNumber":2,"lineContent":"b","review":"rb","commitHash":"c2"},
  {"id":"ccc","filepath":"/src/c.go","lineNumber":3,"lineContent":"c","review":"rc","commitHash":"c3"}
]
JSON

  bats_run_zsh "git-file-watch-review-end bbb"
  [[ "$status" -eq 0 ]]

  local result="$(cat "$COMMENTS_FILE")"
  local count="$(echo "$result" | jq 'length')"
  [[ "$count" -eq 2 ]]
  [[ "$(echo "$result" | jq -r '.[0].id')" == "aaa" ]]
  [[ "$(echo "$result" | jq -r '.[1].id')" == "ccc" ]]
}

# ─── MULTIPLE IDS ───────────────────────────────────────────────────────────

@test "removes 2 matching comments and preserves the remaining 1" {
  cat > "$COMMENTS_FILE" <<'JSON'
[
  {"id":"aaa","filepath":"/src/a.go","lineNumber":1,"lineContent":"a","review":"ra","commitHash":"c1"},
  {"id":"bbb","filepath":"/src/b.go","lineNumber":2,"lineContent":"b","review":"rb","commitHash":"c2"},
  {"id":"ccc","filepath":"/src/c.go","lineNumber":3,"lineContent":"c","review":"rc","commitHash":"c3"}
]
JSON

  bats_run_zsh "git-file-watch-review-end aaa ccc"
  [[ "$status" -eq 0 ]]

  local result="$(cat "$COMMENTS_FILE")"
  local count="$(echo "$result" | jq 'length')"
  [[ "$count" -eq 1 ]]
  [[ "$(echo "$result" | jq -r '.[0].id')" == "bbb" ]]
}

# ─── UNKNOWN ID ─────────────────────────────────────────────────────────────

@test "unknown ID leaves file unchanged" {
  cat > "$COMMENTS_FILE" <<'JSON'
[
  {"id":"aaa","filepath":"/src/a.go","lineNumber":1,"lineContent":"a","review":"ra","commitHash":"c1"}
]
JSON

  local before="$(cat "$COMMENTS_FILE")"
  bats_run_zsh "git-file-watch-review-end zzz"
  [[ "$status" -eq 0 ]]

  local after="$(cat "$COMMENTS_FILE")"
  [[ "$(echo "$after" | jq 'length')" -eq 1 ]]
  [[ "$(echo "$after" | jq -r '.[0].id')" == "aaa" ]]
}

# ─── EDGE CASES ─────────────────────────────────────────────────────────────

@test "no arguments exits with error" {
  bats_run_zsh "git-file-watch-review-end"
  [[ "$status" -ne 0 ]]
}

@test "missing comments file exits silently" {
  bats_run_zsh "git-file-watch-review-end some-id"
  [[ "$status" -eq 0 ]]
}
