bats_load_library 'helper'

setup() {
  bats_tmp_dir
  export OROSHI_TMP_FOLDER="$BATS_TMP_DIR/tmp"
  mkdir -p "$OROSHI_TMP_FOLDER/git-file-watch"

  context-slug() { echo "my-project--main"; }
  bats_mock context-slug
  bats_mock_env OROSHI_TMP_FOLDER "$OROSHI_TMP_FOLDER"
}

# ─── NORMAL CASE ─────────────────────────────────────────────────────────────

@test "outputs simplified JSON with 2 entries from 2 comments" {
  local commentsFile="$OROSHI_TMP_FOLDER/git-file-watch/my-project--main.json"
  cat > "$commentsFile" <<'JSON'
[
  {"id":"abc12345","filepath":"/src/a.go","lineNumber":5,"lineContent":"hello","review":"fix this","commitHash":"deadbeef"},
  {"id":"def67890","filepath":"/src/b.go","lineNumber":10,"lineContent":"world","review":"refactor","commitHash":"cafebabe"}
]
JSON

  bats_run_zsh "git-file-watch-review-start"
  [[ "$status" -eq 0 ]]
  expect_json 'length' '2'
}

@test "output contains id, filepath, lineNumber, lineContent, review" {
  local commentsFile="$OROSHI_TMP_FOLDER/git-file-watch/my-project--main.json"
  cat > "$commentsFile" <<'JSON'
[
  {"id":"abc12345","filepath":"/src/a.go","lineNumber":5,"lineContent":"hello","review":"fix this","commitHash":"deadbeef"}
]
JSON

  bats_run_zsh "git-file-watch-review-start"
  [[ "$status" -eq 0 ]]
  expect_json '.[0].id' 'abc12345'
  expect_json '.[0].filepath' '/src/a.go'
  expect_json '.[0].lineNumber' '5'
  expect_json '.[0].lineContent' 'hello'
  expect_json '.[0].review' 'fix this'
}

@test "output does not contain commitHash" {
  local commentsFile="$OROSHI_TMP_FOLDER/git-file-watch/my-project--main.json"
  cat > "$commentsFile" <<'JSON'
[
  {"id":"abc12345","filepath":"/src/a.go","lineNumber":5,"lineContent":"hello","review":"fix this","commitHash":"deadbeef"}
]
JSON

  bats_run_zsh "git-file-watch-review-start"
  [[ "$status" -eq 0 ]]
  expect_json '.[0] | has("commitHash")' 'false'
}

# ─── EMPTY/MISSING ───────────────────────────────────────────────────────────

@test "missing comments file outputs []" {
  bats_run_zsh "git-file-watch-review-start"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "[]" ]]
}

@test "empty comments file outputs []" {
  local commentsFile="$OROSHI_TMP_FOLDER/git-file-watch/my-project--main.json"
  echo -n "" > "$commentsFile"

  bats_run_zsh "git-file-watch-review-start"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "[]" ]]
}

@test "file containing [] outputs []" {
  local commentsFile="$OROSHI_TMP_FOLDER/git-file-watch/my-project--main.json"
  echo '[]' > "$commentsFile"

  bats_run_zsh "git-file-watch-review-start"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "[]" ]]
}
