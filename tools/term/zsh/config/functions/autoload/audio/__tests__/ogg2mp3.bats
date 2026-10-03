bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Real ffmpeg, real fixture: work on copies so the fixture stays untouched
  cp "$BATS_TEST_DIRNAME/fixtures/silence.ogg" "$BATS_TMP_DIR/a.ogg"
  cp "$BATS_TEST_DIRNAME/fixtures/silence.ogg" "$BATS_TMP_DIR/b.ogg"
}

@test "creates an mp3 with the same basename next to the source" {
  bats_run_zsh "ogg2mp3 $BATS_TMP_DIR/a.ogg"
  [[ "$status" -eq 0 ]]
  [[ -s "$BATS_TMP_DIR/a.mp3" ]]
}

@test "keeps the source ogg" {
  bats_run_zsh "ogg2mp3 $BATS_TMP_DIR/a.ogg"
  [[ -f "$BATS_TMP_DIR/a.ogg" ]]
}

@test "creates one mp3 per source when given several files" {
  bats_run_zsh "ogg2mp3 $BATS_TMP_DIR/a.ogg $BATS_TMP_DIR/b.ogg"
  [[ "$status" -eq 0 ]]
  [[ -s "$BATS_TMP_DIR/a.mp3" ]]
  [[ -s "$BATS_TMP_DIR/b.mp3" ]]
}

@test "overwrites an existing mp3 without prompting" {
  echo "stale" > "$BATS_TMP_DIR/a.mp3"
  bats_run_zsh "ogg2mp3 $BATS_TMP_DIR/a.ogg </dev/null"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/a.mp3")" != "stale" ]]
}

@test "fails without argument" {
  bats_run_zsh "ogg2mp3"
  [[ "$status" -ne 0 ]]
}

@test "fails on a missing file" {
  bats_run_zsh "ogg2mp3 $BATS_TMP_DIR/missing.ogg"
  [[ "$status" -ne 0 ]]
  [[ ! -e "$BATS_TMP_DIR/missing.mp3" ]]
}
