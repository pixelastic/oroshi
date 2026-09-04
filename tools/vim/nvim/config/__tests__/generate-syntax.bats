bats_load_library 'helper'

setup() {
  bats_tmp_dir

  SCRIPT_DIR="$BATS_TMP_DIR/tools/vim/nvim/config"
  INPUT_DIR="$SCRIPT_DIR/lua/oroshi/colorscheme"
  OUTPUT_DIR="$BATS_TMP_DIR/tools/term/zsh/config/theming/dist"
  OUTPUT_FILE="$OUTPUT_DIR/neovim-syntax.json"

  mkdir -p "$SCRIPT_DIR" "$INPUT_DIR" "$OUTPUT_DIR"

  # Copy script under test (fails silently during RED phase)
  cp "$BATS_TEST_DIRNAME/../generate-syntax" "$SCRIPT_DIR/generate-syntax" 2>/dev/null || true
  chmod +x "$SCRIPT_DIR/generate-syntax" 2>/dev/null || true

  # Override OROSHI_ROOT after zshenv sets it
  bats_mock_env "OROSHI_ROOT" "$BATS_TMP_DIR"
}

# Helper: write a syntax.lua fixture and run the script
run_with_fixture() {
  cat > "$INPUT_DIR/syntax.lua" <<< "$1"
  bats_run_zsh "$SCRIPT_DIR/generate-syntax"
}

# Parsing — simple hl call
@test "parses simple hl call into default mapping with correct color" {
  run_with_fixture 'local hl = F.hl
hl("Comment", "comment")'

  [[ "$status" -eq 0 ]]
  local result="$(jq -r '.default.Comment.color' "$OUTPUT_FILE")"
  [[ "$result" == "comment" ]]
}

# Parsing — bold modifier
@test "parses hl call with bold modifier" {
  run_with_fixture 'local hl = F.hl
hl("Boolean", "boolean", { bold = true })'

  [[ "$status" -eq 0 ]]
  [[ "$(jq -r '.default.Boolean.color' "$OUTPUT_FILE")" == "boolean" ]]
  [[ "$(jq '.default.Boolean.bold' "$OUTPUT_FILE")" == "true" ]]
}

# Parsing — italic modifier
@test "parses hl call with italic modifier" {
  run_with_fixture 'local hl = F.hl
hl("@markup.quote.markdown", "gray-4", { italic = true, bold = true })'

  [[ "$status" -eq 0 ]]
  [[ "$(jq -r '.default["@markup.quote.markdown"].color' "$OUTPUT_FILE")" == "gray-4" ]]
  [[ "$(jq '.default["@markup.quote.markdown"].italic' "$OUTPUT_FILE")" == "true" ]]
  [[ "$(jq '.default["@markup.quote.markdown"].bold' "$OUTPUT_FILE")" == "true" ]]
}

# Parsing — language-specific section
@test "parses language-specific section into language key" {
  run_with_fixture 'local hl = F.hl
-- Language specific {{{
-- Bash {{{
hl("@keyword.directive.bash", "yellow")
-- }}}
-- }}}'

  [[ "$status" -eq 0 ]]
  [[ "$(jq -r '.bash["@keyword.directive.bash"].color' "$OUTPUT_FILE")" == "yellow" ]]
  # Must not appear in default
  [[ "$(jq '.default["@keyword.directive.bash"] // empty' "$OUTPUT_FILE")" == "" ]]
}

# Parsing — filetype option
@test "parses filetype option into language key" {
  run_with_fixture 'local hl = F.hl
-- Language specific {{{
-- vue {{{
hl("htmlTag", "orange", { filetype = "vue" })
-- }}}
-- }}}'

  [[ "$status" -eq 0 ]]
  [[ "$(jq -r '.vue.htmlTag.color' "$OUTPUT_FILE")" == "orange" ]]
}

# Parsing — skip none color
@test "skips none color entries" {
  run_with_fixture 'local hl = F.hl
hl("Underlined", "none", { underline = true })
hl("Comment", "comment")'

  [[ "$status" -eq 0 ]]
  [[ "$(jq '.default.Underlined // empty' "$OUTPUT_FILE")" == "" ]]
  # But the non-none entry is present
  [[ "$(jq -r '.default.Comment.color' "$OUTPUT_FILE")" == "comment" ]]
}

# Parsing — skip UI-specific groups
@test "skips UI-specific groups" {
  run_with_fixture 'local hl = F.hl
-- Language specific {{{
-- markdown {{{
hl("RenderMarkdownLink", "link")
hl("RenderMarkdownCode", "string", { bg = "gray-8" })
hl("@markup.strong.markdown_inline", "text", { bold = true })
-- }}}
-- }}}'

  [[ "$status" -eq 0 ]]
  [[ "$(jq '.markdown.RenderMarkdownLink // empty' "$OUTPUT_FILE")" == "" ]]
  [[ "$(jq '.markdown.RenderMarkdownCode // empty' "$OUTPUT_FILE")" == "" ]]
  # Non-UI group is kept
  [[ "$(jq -r '.markdown["@markup.strong.markdown_inline"].color' "$OUTPUT_FILE")" == "text" ]]
}

# Parsing — bg option
@test "parses bg option into output" {
  run_with_fixture 'local hl = F.hl
hl("Todo", "orange-2", { bg = "red-6", bold = true })'

  [[ "$status" -eq 0 ]]
  [[ "$(jq -r '.default.Todo.color' "$OUTPUT_FILE")" == "orange-2" ]]
  [[ "$(jq -r '.default.Todo.bg' "$OUTPUT_FILE")" == "red-6" ]]
  [[ "$(jq '.default.Todo.bold' "$OUTPUT_FILE")" == "true" ]]
}

# Integration — valid JSON
@test "produces valid JSON" {
  run_with_fixture 'local hl = F.hl
hl("Comment", "comment")
hl("Boolean", "boolean", { bold = true })'

  [[ "$status" -eq 0 ]]
  jq empty "$OUTPUT_FILE"
}

# Integration — default key with known entries
@test "JSON contains default key with entries" {
  run_with_fixture 'local hl = F.hl
-- Syntax groups {{{
hl("Comment", "comment")
hl("Function", "function")
-- }}}
-- Treesitter groups {{{
hl("@variable", "variable")
-- }}}'

  [[ "$status" -eq 0 ]]
  [[ "$(jq -r '.default.Comment.color' "$OUTPUT_FILE")" == "comment" ]]
  [[ "$(jq -r '.default.Function.color' "$OUTPUT_FILE")" == "function" ]]
  [[ "$(jq -r '.default["@variable"].color' "$OUTPUT_FILE")" == "variable" ]]
}

# Integration — per-language overrides
@test "JSON contains per-language overrides" {
  run_with_fixture 'local hl = F.hl
hl("Comment", "comment")
-- Language specific {{{
-- lua {{{
hl("@constructor.lua", "punctuation")
-- }}}
-- Bash {{{
hl("@keyword.directive.bash", "yellow")
-- }}}
-- }}}'

  [[ "$status" -eq 0 ]]
  [[ "$(jq -r '.lua["@constructor.lua"].color' "$OUTPUT_FILE")" == "punctuation" ]]
  [[ "$(jq -r '.bash["@keyword.directive.bash"].color' "$OUTPUT_FILE")" == "yellow" ]]
  # Default still has its entry
  [[ "$(jq -r '.default.Comment.color' "$OUTPUT_FILE")" == "comment" ]]
}
