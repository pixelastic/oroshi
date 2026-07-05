bats_load_library 'helper'

setup() {
  bats_tmp_dir

  THEMING_DIR="$BATS_TMP_DIR/tools/term/zsh/config/theming"
  mkdir -p "$THEMING_DIR/src"
  mkdir -p "$THEMING_DIR/dist"

  bats_mock_env "OROSHI_ROOT" "$BATS_TMP_DIR"

  cat >"$THEMING_DIR/src/icons.jsonc" <<'JSONC'
{
  "badge": "★",
  "git": {
    "branch": ""
  }
}
JSONC
}

# --- ZSH output ---

@test "produces dist/icons.zsh with typeset declaration" {
  bats_run_zsh "icons-build"
  [[ "$status" -eq 0 ]]
  [[ -f "$THEMING_DIR/dist/icons.zsh" ]]
  run grep "typeset -gA ICONS" "$THEMING_DIR/dist/icons.zsh"
  [[ "$status" -eq 0 ]]
}

@test "flat key appears as ICONS[badge]=\"glyph\" line in dist/icons.zsh" {
  bats_run_zsh "icons-build"
  run grep 'ICONS\[badge\]="★"' "$THEMING_DIR/dist/icons.zsh"
  [[ "$status" -eq 0 ]]
}

@test "flat key value is accessible after sourcing dist/icons.zsh" {
  bats_run_zsh "icons-build"
  bats_run_zsh "source '${THEMING_DIR}/dist/icons.zsh' && echo \${ICONS[badge]}"
  [[ "${lines[0]}" = "★" ]]
}

@test "nested key git.branch flattens to ICONS[git-branch] in dist/icons.zsh" {
  bats_run_zsh "icons-build"
  bats_run_zsh "source '${THEMING_DIR}/dist/icons.zsh' && echo \${ICONS[git-branch]}"
  [[ "${lines[0]}" = "" ]]
}

# --- JSON output ---

@test "produces dist/icons.json" {
  bats_run_zsh "icons-build"
  [[ -f "$THEMING_DIR/dist/icons.json" ]]
}

@test "dist/icons.json has correct glyph for badge key" {
  bats_run_zsh "icons-build"
  run jq -r '.badge' "$THEMING_DIR/dist/icons.json"
  [[ "$output" = "★" ]]
}

# --- End-to-end through icons-load-definitions ---

@test "after icons-build then icons-load-definitions, badge key is accessible" {
  bats_run_zsh "icons-build && icons-load-definitions && echo \${ICONS[badge]}"
  [[ "${lines[0]}" = "★" ]]
}

# --- Both outputs ---

@test "generates both dist/icons.zsh and dist/icons.json in a single run" {
  bats_run_zsh "icons-build"
  [[ "$status" -eq 0 ]]
  [[ -f "$THEMING_DIR/dist/icons.zsh" ]]
  [[ -f "$THEMING_DIR/dist/icons.json" ]]
}
