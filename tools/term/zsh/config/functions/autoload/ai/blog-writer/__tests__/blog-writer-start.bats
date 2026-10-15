bats_load_library 'helper'

setup() {
  bats_tmp_dir
  export OROSHI_FOLDER_STATE="$BATS_TMP_DIR/state"
  bats_mock_env OROSHI_FOLDER_STATE "$OROSHI_FOLDER_STATE"
}

@test "creates the article folder and its images subfolder" {
  bats_run_zsh "blog-writer-start my-article"
  [[ "$status" -eq 0 ]]
  [[ -d "$OROSHI_FOLDER_STATE/claude/blog-writer/my-article" ]]
  [[ -d "$OROSHI_FOLDER_STATE/claude/blog-writer/my-article/images" ]]
}

@test "prints JSON with the folder, brief, interview, draft and images paths" {
  bats_run_zsh "blog-writer-start my-article"
  local folder="$OROSHI_FOLDER_STATE/claude/blog-writer/my-article"
  [[ "$status" -eq 0 ]]
  expect_json '.folder' "$folder"
  expect_json '.brief' "$folder/brief.md"
  expect_json '.interview' "$folder/interview.md"
  expect_json '.draft' "$folder/draft.md"
  expect_json '.images' "$folder/images"
}

@test "does not create the brief, interview or draft files" {
  bats_run_zsh "blog-writer-start my-article"
  local folder="$OROSHI_FOLDER_STATE/claude/blog-writer/my-article"
  [[ ! -e "$folder/brief.md" ]]
  [[ ! -e "$folder/interview.md" ]]
  [[ ! -e "$folder/draft.md" ]]
}

@test "starting the same slug twice keeps existing files untouched" {
  bats_run_zsh "blog-writer-start my-article"
  local folder="$OROSHI_FOLDER_STATE/claude/blog-writer/my-article"
  echo "my draft" > "$folder/draft.md"
  echo "my image" > "$folder/images/1.png"

  bats_run_zsh "blog-writer-start my-article"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$folder/draft.md")" == "my draft" ]]
  [[ "$(cat "$folder/images/1.png")" == "my image" ]]
}

@test "starting the same slug twice prints the same paths" {
  bats_run_zsh "blog-writer-start my-article"
  local first="$output"

  bats_run_zsh "blog-writer-start my-article"
  [[ "$output" == "$first" ]]
}

@test "different slugs get different folders" {
  bats_run_zsh "blog-writer-start first-article"
  local first="$(echo "$output" | jq --raw-output '.folder')"

  bats_run_zsh "blog-writer-start second-article"
  local second="$(echo "$output" | jq --raw-output '.folder')"

  [[ "$first" != "$second" ]]
  [[ -d "$first" ]]
  [[ -d "$second" ]]
}

@test "fails with a usage message when no slug is given" {
  bats_run_zsh "blog-writer-start"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Usage"* ]]
}

@test "fails when the slug contains a path separator" {
  bats_run_zsh "blog-writer-start a/b"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Invalid slug"* ]]
  [[ ! -e "$OROSHI_FOLDER_STATE/claude/blog-writer/a" ]]
}

@test "fails when the slug starts with a dot" {
  bats_run_zsh "blog-writer-start ..hidden"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Invalid slug"* ]]
}
