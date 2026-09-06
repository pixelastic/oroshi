bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "errors with usage when no argument provided" {
  bats_run_zsh "txt2svg"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Usage"* ]]
}

@test "writes SVG file to disk with slugified name from first 5 words" {
  claude-api() {
    echo '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 240"><rect/></svg>'
  }
  svg-fix() { :; }
  bats_mock claude-api svg-fix
  bats_disable_worktree_aware

  bats_run_zsh "cd $BATS_TMP_DIR && txt2svg 'A colored butterfly next to a beautiful rose in a garden'"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/a-colored-butterfly-next-to.svg" ]]
}

@test "writes SVG file to --output path" {
  claude-api() {
    echo '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 240"><rect/></svg>'
  }
  svg-fix() { :; }
  bats_mock claude-api svg-fix

  bats_run_zsh "txt2svg --output $BATS_TMP_DIR/custom.svg 'A butterfly'"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/custom.svg" ]]
}

@test "prints output path to stdout" {
  claude-api() {
    echo '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 240"><rect/></svg>'
  }
  svg-fix() { :; }
  bats_mock claude-api svg-fix

  bats_run_zsh "txt2svg --output $BATS_TMP_DIR/out.svg 'A butterfly'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"$BATS_TMP_DIR/out.svg"* ]]
}

@test "strips markdown fences from claude-api response" {
  claude-api() {
    printf '```svg\n<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 240"><rect/></svg>\n```\n'
  }
  svg-fix() { :; }
  bats_mock claude-api svg-fix

  bats_run_zsh "txt2svg --output $BATS_TMP_DIR/out.svg 'A butterfly'"
  [[ "$status" -eq 0 ]]
  run ! grep -q '```' "$BATS_TMP_DIR/out.svg"
}

@test "calls svg-fix on the generated SVG" {
  claude-api() {
    echo '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 240"><rect/></svg>'
  }
  svg-fix() { echo "$1" >> "$BATS_TMP_DIR/svgfix_calls.txt"; }
  bats_mock claude-api svg-fix

  bats_run_zsh "txt2svg --output $BATS_TMP_DIR/out.svg 'A butterfly'"
  [[ "$status" -eq 0 ]]

  [[ -f "$BATS_TMP_DIR/svgfix_calls.txt" ]]
  [[ $(wc -l < "$BATS_TMP_DIR/svgfix_calls.txt") -eq 1 ]]
}

@test "passes hardcoded system prompt to claude-api" {
  claude-api() {
    echo "$@" >> "$BATS_TMP_DIR/claude_calls.txt"
    echo '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 240"><rect/></svg>'
  }
  svg-fix() { :; }
  bats_mock claude-api svg-fix

  bats_run_zsh "txt2svg --output $BATS_TMP_DIR/out.svg 'Lulu a peur'"
  [[ "$status" -eq 0 ]]

  local call="$(cat "$BATS_TMP_DIR/claude_calls.txt")"
  [[ "$call" == *"--system"* ]]
  [[ "$call" == *"SVG"* ]]
  [[ "$call" == *"Lulu a peur"* ]]
}
