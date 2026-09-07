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
  svg-lint() { echo "[]"; }
  bats_mock claude-api svg-fix svg-lint
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
  svg-lint() { echo "[]"; }
  bats_mock claude-api svg-fix svg-lint

  bats_run_zsh "txt2svg --output $BATS_TMP_DIR/custom.svg 'A butterfly'"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/custom.svg" ]]
}

@test "prints output path to stdout" {
  claude-api() {
    echo '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 240"><rect/></svg>'
  }
  svg-fix() { :; }
  svg-lint() { echo "[]"; }
  bats_mock claude-api svg-fix svg-lint

  bats_run_zsh "txt2svg --output $BATS_TMP_DIR/out.svg 'A butterfly'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"$BATS_TMP_DIR/out.svg"* ]]
}

@test "strips markdown fences from claude-api response" {
  claude-api() {
    printf '```svg\n<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 240"><rect/></svg>\n```\n'
  }
  svg-fix() { :; }
  svg-lint() { echo "[]"; }
  bats_mock claude-api svg-fix svg-lint

  bats_run_zsh "txt2svg --output $BATS_TMP_DIR/out.svg 'A butterfly'"
  [[ "$status" -eq 0 ]]
  run ! grep -q '```' "$BATS_TMP_DIR/out.svg"
}

@test "calls svg-fix on the generated SVG" {
  claude-api() {
    echo '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 240"><rect/></svg>'
  }
  svg-fix() { echo "$1" >> "$BATS_TMP_DIR/svgfix_calls.txt"; }
  svg-lint() { echo "[]"; }
  bats_mock claude-api svg-fix svg-lint

  bats_run_zsh "txt2svg --output $BATS_TMP_DIR/out.svg 'A butterfly'"
  [[ "$status" -eq 0 ]]

  [[ -f "$BATS_TMP_DIR/svgfix_calls.txt" ]]
  [[ $(wc -l < "$BATS_TMP_DIR/svgfix_calls.txt") -eq 1 ]]
}

@test "errors when claude-api fails" {
  claude-api() { return 1; }
  svg-fix() { :; }
  bats_mock claude-api svg-fix

  bats_run_zsh "txt2svg --output $BATS_TMP_DIR/out.svg 'A butterfly'"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"claude-api failed"* ]]
}

@test "errors when claude-api returns empty response" {
  claude-api() { echo ""; }
  svg-fix() { :; }
  bats_mock claude-api svg-fix

  bats_run_zsh "txt2svg --output $BATS_TMP_DIR/out.svg 'A butterfly'"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"empty response"* ]]
}

@test "retries with Claude when svg-lint finds issues" {
  local callCount=0
  claude-api() {
    callCount=$((callCount + 1))
    echo "$callCount" >> "$BATS_TMP_DIR/api_calls.txt"
    echo '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 240"><rect/></svg>'
  }
  svg-fix() { :; }
  local lintCallCount=0
  svg-lint() {
    lintCallCount=$((lintCallCount + 1))
    echo "$lintCallCount" >> "$BATS_TMP_DIR/lint_calls.txt"
    # Fail first lint, pass second
    if [[ $(wc -l < "$BATS_TMP_DIR/lint_calls.txt") -le 1 ]]; then
      echo '[{"message":"unclosed tag","line":1}]'
      return 1
    fi
    echo "[]"
  }
  bats_mock claude-api svg-fix svg-lint

  bats_run_zsh "txt2svg --output $BATS_TMP_DIR/out.svg 'A butterfly'"
  [[ "$status" -eq 0 ]]

  # Initial call + 1 fix attempt = 2 API calls
  [[ $(wc -l < "$BATS_TMP_DIR/api_calls.txt") -eq 2 ]]
}

@test "fails after max retry attempts with lint details" {
  claude-api() {
    echo '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 240"><rect/></svg>'
  }
  svg-fix() { :; }
  svg-lint() {
    echo '[{"message":"unclosed tag"}]'
    return 1
  }
  bats_mock claude-api svg-fix svg-lint

  bats_run_zsh "txt2svg --output $BATS_TMP_DIR/out.svg 'A butterfly'"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"lint issues after"* ]]
}

@test "passes hardcoded system prompt to claude-api" {
  claude-api() {
    echo "$@" >> "$BATS_TMP_DIR/claude_calls.txt"
    echo '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 240"><rect/></svg>'
  }
  svg-fix() { :; }
  svg-lint() { echo "[]"; }
  bats_mock claude-api svg-fix svg-lint

  bats_run_zsh "txt2svg --output $BATS_TMP_DIR/out.svg 'Lulu a peur'"
  [[ "$status" -eq 0 ]]

  local call="$(cat "$BATS_TMP_DIR/claude_calls.txt")"
  [[ "$call" == *"--system"* ]]
  [[ "$call" == *"SVG"* ]]
  [[ "$call" == *"Lulu a peur"* ]]
}
