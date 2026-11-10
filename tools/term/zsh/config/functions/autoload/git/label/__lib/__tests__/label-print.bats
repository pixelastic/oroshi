bats_load_library 'helper'

setup() {
  bats_tmp_dir
  sourcePrefix="source '${OROSHI_ROOT}/tools/term/zsh/config/functions/autoload/git/label/__lib/label-print.zsh'"

  # git-label-list-raw records its arguments and lists two labels
  git-label-list-raw() {
    echo "$*" >> "$BATS_TMP_DIR/list-args"
    echo "bug▮#d73a4a▮Something is broken"
    echo "help wanted▮#008672▮"
  }
  bats_mock git-label-list-raw
}

run_print() {
  bats_run_zsh "$sourcePrefix && git-label-print $*"
}

@test "prints the label as JSON" {
  run_print "bug"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --compact-output <<< "$output")" == '{"name":"bug","color":"#d73a4a","description":"Something is broken"}' ]]
}

@test "matches the name without regard to case" {
  run_print "'Help Wanted'"
  [[ "$status" -eq 0 ]]
  [[ "$(jq --raw-output '.name' <<< "$output")" == "help wanted" ]]
}

@test "lists the labels of another repo with --repo" {
  run_print "bug --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/list-args")" == "--repo pixelastic/imoen" ]]
}

@test "fails when the label does not exist" {
  run_print "missing"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Label not found: missing"* ]]
}
