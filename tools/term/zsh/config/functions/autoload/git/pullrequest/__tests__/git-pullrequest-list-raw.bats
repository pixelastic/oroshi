bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # git-pullrequest-search records its arguments and prints the content of
  # search-response. The count cache is redirected to a folder of the sandbox
  export OROSHI_FOLDER_STATE="$BATS_TMP_DIR/state"
  git-pullrequest-search() {
    echo "$*" > "$BATS_TMP_DIR/search-args"
    cat "$BATS_TMP_DIR/search-response"
  }
  git-github-project() { echo "pixelastic/imoen"; }
  bats_mock git-pullrequest-search git-github-project

  echo '[]' > "$BATS_TMP_DIR/search-response"
}

@test "prints the fields in the documented order" {
  cat > "$BATS_TMP_DIR/search-response" <<'JSON'
[{"id":27,"title":"Add login","state":"open","date":"2026-01-02T03:04:05Z","author":"pixelastic","url":"https://github.com/pixelastic/imoen/pull/27","labels":["bug"],"body":"Some body","head":"feature","base":"main","checks":"success"}]
JSON

  bats_run_zsh "git-pullrequest-list-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "27▮Add login▮open▮2026-01-02T03:04:05Z▮pixelastic▮https://github.com/pixelastic/imoen/pull/27▮bug▮feature▮main▮success" ]]
}

@test "prints one pull request per line" {
  cat > "$BATS_TMP_DIR/search-response" <<'JSON'
[
  {"id":1,"title":"First","state":"open","date":"d","author":"a","url":"u1","labels":[],"body":"","head":"h1","base":"main","checks":""},
  {"id":2,"title":"Second","state":"merged","date":"d","author":"b","url":"u2","labels":[],"body":"","head":"h2","base":"main","checks":"failure"}
]
JSON

  bats_run_zsh "git-pullrequest-list-raw"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]
  [[ "${lines[0]}" == "1▮First▮open▮"* ]]
  [[ "${lines[1]}" == "2▮Second▮merged▮"* ]]
}

@test "joins several labels with ▯" {
  cat > "$BATS_TMP_DIR/search-response" <<'JSON'
[{"id":1,"title":"T","state":"open","date":"d","author":"a","url":"u","labels":["bug","help wanted"],"body":"","head":"h","base":"main","checks":""}]
JSON

  bats_run_zsh "git-pullrequest-list-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"▮bug▯help wanted▮h▮main▮" ]]
}

@test "prints empty fields when there is no label and no checks" {
  cat > "$BATS_TMP_DIR/search-response" <<'JSON'
[{"id":1,"title":"T","state":"draft","date":"d","author":"a","url":"u","labels":[],"body":"","head":"h","base":"main","checks":""}]
JSON

  bats_run_zsh "git-pullrequest-list-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "1▮T▮draft▮d▮a▮u▮▮h▮main▮" ]]
}

@test "forwards every flag to git-pullrequest-search" {
  bats_run_zsh "git-pullrequest-list-raw 'login bug' --state merged --author renovate --label bug --limit 5 --date-min 2026-01-01 --date-max 2026-02-01 --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
  local args="$(cat "$BATS_TMP_DIR/search-args")"
  [[ "$args" == *"login bug"* ]]
  [[ "$args" == *"--state merged"* ]]
  [[ "$args" == *"--author renovate"* ]]
  [[ "$args" == *"--label bug"* ]]
  [[ "$args" == *"--limit 5"* ]]
  [[ "$args" == *"--date-min 2026-01-01"* ]]
  [[ "$args" == *"--date-max 2026-02-01"* ]]
  [[ "$args" == *"--repo pixelastic/imoen"* ]]
}

@test "prints nothing when nothing matches" {
  bats_run_zsh "git-pullrequest-list-raw"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "does not write the count cache" {
  bats_run_zsh "git-pullrequest-list-raw"
  [[ "$status" -eq 0 ]]
  [[ ! -e "$OROSHI_FOLDER_STATE" ]]
}
