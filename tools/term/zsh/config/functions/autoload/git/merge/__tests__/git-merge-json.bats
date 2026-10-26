bats_load_library 'helper'

setup() {
  bats_tmp_dir
  echo '["a", "c"]' >"$BATS_TMP_DIR/base.json"
}

@test "keeps the additions of both sides" {
  echo '["a", "b", "c"]' >"$BATS_TMP_DIR/ours.json"
  echo '["a", "c", "d"]' >"$BATS_TMP_DIR/theirs.json"

  bats_run_zsh "git-merge-json --stdout $BATS_TMP_DIR/base.json $BATS_TMP_DIR/ours.json $BATS_TMP_DIR/theirs.json | jq --compact-output ."
  [[ "$status" -eq 0 ]]
  [[ "$output" = '["a","b","c","d"]' ]]
}

@test "keeps a deletion made by one side" {
  echo '["a"]' >"$BATS_TMP_DIR/ours.json"
  echo '["a", "c", "d"]' >"$BATS_TMP_DIR/theirs.json"

  bats_run_zsh "git-merge-json --stdout $BATS_TMP_DIR/base.json $BATS_TMP_DIR/ours.json $BATS_TMP_DIR/theirs.json | jq --compact-output ."
  [[ "$output" = '["a","d"]' ]]
}

@test "does not duplicate an entry added by both sides" {
  echo '["a", "c", "d"]' >"$BATS_TMP_DIR/ours.json"
  echo '["a", "c", "d"]' >"$BATS_TMP_DIR/theirs.json"

  bats_run_zsh "git-merge-json --stdout $BATS_TMP_DIR/base.json $BATS_TMP_DIR/ours.json $BATS_TMP_DIR/theirs.json | jq --compact-output ."
  [[ "$output" = '["a","c","d"]' ]]
}

@test "sorts the result like json-array-sort" {
  echo '["gdoc2md", "gdoc-read"]' >"$BATS_TMP_DIR/ours.json"
  echo '["gdoc-comment-list-raw"]' >"$BATS_TMP_DIR/theirs.json"
  echo '[]' >"$BATS_TMP_DIR/base.json"

  bats_run_zsh "git-merge-json --stdout $BATS_TMP_DIR/base.json $BATS_TMP_DIR/ours.json $BATS_TMP_DIR/theirs.json | jq --compact-output ."
  [[ "$output" = '["gdoc2md","gdoc-comment-list-raw","gdoc-read"]' ]]
}

@test "merges two files when no base is given" {
  echo '["a", "b"]' >"$BATS_TMP_DIR/ours.json"
  echo '["b", "c"]' >"$BATS_TMP_DIR/theirs.json"

  bats_run_zsh "git-merge-json --stdout $BATS_TMP_DIR/ours.json $BATS_TMP_DIR/theirs.json | jq --compact-output ."
  [[ "$output" = '["a","b","c"]' ]]
}

@test "writes the result into the ours file by default" {
  echo '["a", "b", "c"]' >"$BATS_TMP_DIR/ours.json"
  echo '["a", "c", "d"]' >"$BATS_TMP_DIR/theirs.json"

  bats_run_zsh "git-merge-json $BATS_TMP_DIR/base.json $BATS_TMP_DIR/ours.json $BATS_TMP_DIR/theirs.json"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
  [[ "$(jq --compact-output . "$BATS_TMP_DIR/ours.json")" = '["a","b","c","d"]' ]]
}

@test "fails when a file is not a JSON array" {
  echo '{"a": 1}' >"$BATS_TMP_DIR/ours.json"
  echo '["a"]' >"$BATS_TMP_DIR/theirs.json"

  bats_run_zsh "git-merge-json $BATS_TMP_DIR/base.json $BATS_TMP_DIR/ours.json $BATS_TMP_DIR/theirs.json"
  [[ "$status" -ne 0 ]]
}

@test "leaves the ours file untouched with --stdout" {
  echo '["a", "b", "c"]' >"$BATS_TMP_DIR/ours.json"
  echo '["a", "c", "d"]' >"$BATS_TMP_DIR/theirs.json"

  bats_run_zsh "git-merge-json --stdout $BATS_TMP_DIR/base.json $BATS_TMP_DIR/ours.json $BATS_TMP_DIR/theirs.json"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output . "$BATS_TMP_DIR/ours.json")" = '["a","b","c"]' ]]
}
