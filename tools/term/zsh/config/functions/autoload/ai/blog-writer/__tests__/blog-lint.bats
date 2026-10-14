bats_load_library 'helper'

setup() {
  bats_tmp_dir
  # Fake prose-lint: prints the JSON stored in $BATS_TMP_DIR/vale.json (default
  # empty array), records its arguments, and fails when the array is not empty
  prose-lint() {
    printf '%s\n' "$@" > "$BATS_TMP_DIR/prose-lint-args"
    local json="$(cat "$BATS_TMP_DIR/vale.json" 2>/dev/null || printf '[]')"
    printf '%s\n' "$json"
    [[ "$json" == '[]' ]]
  }
  # Fake markdown-wordcount: prints the number stored in $BATS_TMP_DIR/wordcount
  markdown-wordcount() { cat "$BATS_TMP_DIR/wordcount"; }
  bats_mock prose-lint markdown-wordcount
  printf '10' > "$BATS_TMP_DIR/wordcount"
  printf 'Some prose.\n' > "$BATS_TMP_DIR/draft.md"
}

@test "clean draft: prints an empty array and succeeds" {
  bats_run_zsh "blog-lint $BATS_TMP_DIR/draft.md"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "lints with the blog profile" {
  bats_run_zsh "blog-lint $BATS_TMP_DIR/draft.md"
  [[ "$(cat "$BATS_TMP_DIR/prose-lint-args")" == *"--profile"*"blog"*"$BATS_TMP_DIR/draft.md"* ]]
}

@test "Vale violation: relayed in the JSON with its fields, exit 1" {
  printf '[{"line":3,"rule":"write-good.Weasel","severity":"warning","match":"very","message":"weasel word"}]' > "$BATS_TMP_DIR/vale.json"
  bats_run_zsh "blog-lint $BATS_TMP_DIR/draft.md"
  [[ "$status" -eq 1 ]]
  [[ "$(printf '%s' "$output" | jq --compact-output '.')" == '[{"line":3,"rule":"write-good.Weasel","severity":"warning","match":"very","message":"weasel word"}]' ]]
}

@test "over 2000 words: adds a word-limit violation and fails" {
  printf '2001' > "$BATS_TMP_DIR/wordcount"
  bats_run_zsh "blog-lint $BATS_TMP_DIR/draft.md"
  [[ "$status" -eq 1 ]]
  [[ "$(printf '%s' "$output" | jq 'length')" -eq 1 ]]
  [[ "$(printf '%s' "$output" | jq --raw-output '.[0].severity')" == 'error' ]]
  [[ "$(printf '%s' "$output" | jq --raw-output '.[0].line')" == '1' ]]
  [[ "$(printf '%s' "$output" | jq --raw-output '.[0].message')" == *"2001"*"2000"* ]]
}

@test "word-limit violation has the 5 prose-lint keys" {
  printf '2001' > "$BATS_TMP_DIR/wordcount"
  bats_run_zsh "blog-lint $BATS_TMP_DIR/draft.md"
  local keys="$(printf '%s' "$output" | jq --raw-output '.[0] | keys | sort | join(",")')"
  [[ "$keys" == 'line,match,message,rule,severity' ]]
}

@test "exactly 2000 words: passes" {
  printf '2000' > "$BATS_TMP_DIR/wordcount"
  bats_run_zsh "blog-lint $BATS_TMP_DIR/draft.md"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "Vale violations and word-limit violation appear in one array" {
  printf '[{"line":3,"rule":"write-good.Weasel","severity":"warning","match":"very","message":"weasel word"}]' > "$BATS_TMP_DIR/vale.json"
  printf '2500' > "$BATS_TMP_DIR/wordcount"
  bats_run_zsh "blog-lint $BATS_TMP_DIR/draft.md"
  [[ "$status" -eq 1 ]]
  [[ "$(printf '%s' "$output" | jq 'length')" -eq 2 ]]
  [[ "$(printf '%s' "$output" | jq --raw-output '.[0].rule')" == 'write-good.Weasel' ]]
}

@test "missing argument: fails with a usage message" {
  bats_run_zsh "blog-lint"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Usage"* ]]
}

@test "missing file: fails with a usage message" {
  bats_run_zsh "blog-lint $BATS_TMP_DIR/nope.md"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Usage"* ]]
}

# This test uses the real Vale and the real word counter
@test "draft with contractions: passes" {
  # Empty the mock file so the real commands run
  : > "$MOCK_OVERRIDE"
  local file="$BATS_TMP_DIR/contractions.md"
  printf 'I don'"'"'t think it'"'"'s a problem.\n' > "$file"
  bats_run_zsh "blog-lint $file"
  [[ "$output" != *"NoContractions"* ]]
  [[ "$status" -eq 0 ]]
}

# This test uses the real Vale and the real word counter
@test "sentence starting with So: passes" {
  # Empty the mock file so the real commands run
  : > "$MOCK_OVERRIDE"
  local file="$BATS_TMP_DIR/so.md"
  printf 'The build was slow. So I cached the dependencies.\n' > "$file"
  bats_run_zsh "blog-lint $file"
  [[ "$output" != *"write-good.So"* ]]
  [[ "$output" == '[]' ]]
  [[ "$status" -eq 0 ]]
}

# This test uses the real Vale and the real word counter
@test "paragraph starting with But: passes" {
  # Empty the mock file so the real commands run
  : > "$MOCK_OVERRIDE"
  local file="$BATS_TMP_DIR/but.md"
  printf 'The cache looked right.\n\nBut the build stayed slow.\n' > "$file"
  bats_run_zsh "blog-lint $file"
  [[ "$output" != *"proselint.But"* ]]
  [[ "$output" == '[]' ]]
  [[ "$status" -eq 0 ]]
}

# This test uses the real Vale and the real word counter
@test "other blog rules still fire next to a So opener" {
  # Empty the mock file so the real commands run
  : > "$MOCK_OVERRIDE"
  local file="$BATS_TMP_DIR/others.md"
  printf 'So the build was 1st in line.\n' > "$file"
  bats_run_zsh "blog-lint $file"
  [[ "$output" == *"Google.Ordinal"* ]]
  [[ "$status" -eq 1 ]]
}
