bats_load_library 'helper'

setup() {
  bats_tmp_dir

  # Mirror the themes directory structure in a temp dir
  local THEMES_DIR="$OROSHI_ROOT/tools/ai/claude/config/themes"
  WORK_DIR="$BATS_TMP_DIR/themes"
  mkdir -p "$WORK_DIR/src"
  cp "$THEMES_DIR/generate-theme" "$WORK_DIR/"
  cp "$THEMES_DIR/src/oroshi.json" "$WORK_DIR/src/"

  # Wrapper: inject COLORS, mock colors-load-definitions, run generate-theme
  WRAPPER="$BATS_TMP_DIR/run.zsh"
  cat >"$WRAPPER" <<WRAPPER
typeset -gA COLORS
COLORS[claude-commandMode:hex]="#0f766e"
COLORS[claude-text:hex]="#ffffff"
COLORS[cyan:hex]="#0891b2"
COLORS[orange:hex]="#ea580c"
COLORS[pink-4:hex]="#db2777"
COLORS[red:hex]="#dc2626"
colors-load-definitions() { }
source $WORK_DIR/generate-theme
WRAPPER

  # Run generate-theme once for all tests
  bats_run_zsh "source $WRAPPER"
  OUTPUT="$WORK_DIR/dist/oroshi.json"
}

# Helper: assert jq value from a file
assert_jq() {
  local jqPath="$1"
  local expected="$2"
  local file="$3"
  local actual="$(jq -r "$jqPath" "$file")"

  [[ "$actual" == "$expected" ]] && return 0

  echo "assert_jq $jqPath: expected '$expected', got '$actual'"
  return 1
}

# --- File creation ---

@test "creates dist/oroshi.json" {
  [[ -f "$OUTPUT" ]]
}

@test "dist/oroshi.json is valid JSON" {
  jq . "$OUTPUT" >/dev/null
}

# --- Templatized values resolve to hex ---

@test "bashBorder is resolved hex (teal-6), not rgb()" {
  assert_jq '.overrides.bashBorder' '#0f766e' "$OUTPUT"
}

@test "text is resolved hex (white), not rgb()" {
  assert_jq '.overrides.text' '#ffffff' "$OUTPUT"
}

@test "cyan subagent value is resolved hex" {
  assert_jq '.overrides.cyan_FOR_SUBAGENTS_ONLY' '#0891b2' "$OUTPUT"
}

@test "orange subagent value is resolved hex" {
  assert_jq '.overrides.orange_FOR_SUBAGENTS_ONLY' '#ea580c' "$OUTPUT"
}

@test "pink subagent value is resolved hex" {
  assert_jq '.overrides.pink_FOR_SUBAGENTS_ONLY' '#db2777' "$OUTPUT"
}

@test "red subagent value is resolved hex" {
  assert_jq '.overrides.red_FOR_SUBAGENTS_ONLY' '#dc2626' "$OUTPUT"
}

# --- Hardcoded values preserved ---

@test "promptBorder is hardcoded rgb, not templatized" {
  assert_jq '.overrides.promptBorder' 'rgb(136,136,136)' "$OUTPUT"
}

@test "other rgb() values are preserved as-is" {
  assert_jq '.overrides.autoAccept' 'rgb(175,135,255)' "$OUTPUT"
}
