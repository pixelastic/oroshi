bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # git-issue-search records its arguments and prints the content of
  # search-response. The count cache is redirected to a folder of the sandbox
  export OROSHI_FOLDER_STATE="$BATS_TMP_DIR/state"
  git-issue-search() {
    echo "$*" > "$BATS_TMP_DIR/search-args"
    cat "$BATS_TMP_DIR/search-response"
  }
  git-github-project() { echo "pixelastic/imoen"; }
  bats_mock git-issue-search git-github-project

  echo '[]' > "$BATS_TMP_DIR/search-response"
}

@test "prints the fields in the documented order" {
  cat > "$BATS_TMP_DIR/search-response" <<'EOF'
[{"number":42,"title":"Login bug","state":"open","date":"2026-01-02T03:04:05Z","author":"pixelastic","url":"https://github.com/pixelastic/imoen/issues/42","labels":["bug"],"body":"Some body"}]
EOF

  bats_run_zsh "git-issue-list-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "42▮Login bug▮open▮2026-01-02T03:04:05Z▮pixelastic▮https://github.com/pixelastic/imoen/issues/42▮bug" ]]
}

@test "prints one issue per line" {
  cat > "$BATS_TMP_DIR/search-response" <<'EOF'
[
  {"number":1,"title":"First","state":"open","date":"2026-01-01T00:00:00Z","author":"a","url":"u1","labels":["bug"],"body":""},
  {"number":2,"title":"Second","state":"closed","date":"2026-01-02T00:00:00Z","author":"b","url":"u2","labels":["bug"],"body":""}
]
EOF

  bats_run_zsh "git-issue-list-raw"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]
  [[ "${lines[0]}" == "1▮First▮open▮"* ]]
  [[ "${lines[1]}" == "2▮Second▮closed▮"* ]]
}

@test "joins several labels with ▯" {
  cat > "$BATS_TMP_DIR/search-response" <<'EOF'
[{"number":1,"title":"T","state":"open","date":"d","author":"a","url":"u","labels":["bug","help wanted"],"body":""}]
EOF

  bats_run_zsh "git-issue-list-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"▮bug▯help wanted" ]]
}

@test "prints an empty field when an issue has no label" {
  cat > "$BATS_TMP_DIR/search-response" <<'EOF'
[{"number":1,"title":"T","state":"open","date":"d","author":"a","url":"u","labels":[],"body":""}]
EOF

  bats_run_zsh "git-issue-list-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "1▮T▮open▮d▮a▮u▮" ]]
}

@test "forwards every flag to git-issue-search" {
  bats_run_zsh "git-issue-list-raw 'login bug' --state closed --author renovate --label bug --limit 5 --date-min 2026-01-01 --date-max 2026-02-01 --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
  local args="$(cat "$BATS_TMP_DIR/search-args")"
  [[ "$args" == *"login bug"* ]]
  [[ "$args" == *"--state closed"* ]]
  [[ "$args" == *"--author renovate"* ]]
  [[ "$args" == *"--label bug"* ]]
  [[ "$args" == *"--limit 5"* ]]
  [[ "$args" == *"--date-min 2026-01-01"* ]]
  [[ "$args" == *"--date-max 2026-02-01"* ]]
  [[ "$args" == *"--repo pixelastic/imoen"* ]]
}

@test "prints nothing when nothing matches" {
  bats_run_zsh "git-issue-list-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "does not write the count cache" {
  bats_run_zsh "git-issue-list-raw"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$OROSHI_FOLDER_STATE" ]]
}
