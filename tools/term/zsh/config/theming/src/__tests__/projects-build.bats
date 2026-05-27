bats_load_library 'helper'

PROJECTS_BUILD="$(realpath "${BATS_TEST_DIRNAME}/../projects-build")"

setup() {
  bats_tmp_dir

  export THEMING_ROOT="$BATS_TMP_DIR/theming"
  mkdir -p "$THEMING_ROOT/src"
  mkdir -p "$THEMING_ROOT/env"

  cat > "$THEMING_ROOT/env/colors.zsh" << 'COLORS'
export COLOR_GREEN_8="78"
export COLOR_GREEN_8_HEXA="#166534"
export COLOR_DARK_GREEN="211"
export COLOR_DARK_GREEN_HEXA="#0f1a0f"
export COLOR_GRAY_9="139"
export COLOR_GRAY_9_HEXA="#111827"
export COLOR_GREEN="2"
export COLOR_GREEN_HEXA="#38a169"
COLORS

  cat > "$THEMING_ROOT/src/projects.json" << 'JSON'
{
  "myproject": {
    "background": "GREEN_8",
    "foreground": "GRAY_9",
    "icon": "X",
    "path": "~/projects/myproject"
  },
  "icononly": {
    "icon": "I"
  }
}
JSON
}

teardown() {
  bats_cleanup
}

@test "produces dist/projects.json" {
  bats_run_script "$PROJECTS_BUILD"
  [ "$status" -eq 0 ]
  [ -f "$THEMING_ROOT/dist/projects.json" ]
}

@test "produces dist/projects.zsh" {
  bats_run_script "$PROJECTS_BUILD"
  [ "$status" -eq 0 ]
  [ -f "$THEMING_ROOT/dist/projects.zsh" ]
}

@test "dist/projects.json has correct background object" {
  bats_run_script "$PROJECTS_BUILD"
  [ "$(jq -r '.myproject.background.name' "$THEMING_ROOT/dist/projects.json")" = "GREEN_8" ]
  [ "$(jq -r '.myproject.background.ansi' "$THEMING_ROOT/dist/projects.json")" = "78" ]
  [ "$(jq -r '.myproject.background.hex' "$THEMING_ROOT/dist/projects.json")" = "#166534" ]
}

@test "backgroundInactive derived from numeric suffix (GREEN_8 -> DARK_GREEN)" {
  bats_run_script "$PROJECTS_BUILD"
  [ "$(jq -r '.myproject.backgroundInactive.name' "$THEMING_ROOT/dist/projects.json")" = "DARK_GREEN" ]
  [ "$(jq -r '.myproject.backgroundInactive.ansi' "$THEMING_ROOT/dist/projects.json")" = "211" ]
  [ "$(jq -r '.myproject.backgroundInactive.hex' "$THEMING_ROOT/dist/projects.json")" = "#0f1a0f" ]
}

@test "backgroundInactive derived without numeric suffix (GREEN -> DARK_GREEN)" {
  cat > "$THEMING_ROOT/src/projects.json" << 'JSON'
{
  "nosuffix": {
    "background": "GREEN",
    "foreground": "GRAY_9",
    "icon": "G"
  }
}
JSON
  bats_run_script "$PROJECTS_BUILD"
  [ "$(jq -r '.nosuffix.backgroundInactive.name' "$THEMING_ROOT/dist/projects.json")" = "DARK_GREEN" ]
}

@test "hideNameInPrompt is true in dist when true in src" {
  cat > "$THEMING_ROOT/src/projects.json" << 'JSON'
{
  "myproject": {
    "background": "GREEN_8",
    "foreground": "GRAY_9",
    "icon": "X",
    "hideNameInPrompt": true
  }
}
JSON
  bats_run_script "$PROJECTS_BUILD"
  [ "$(jq -r '.myproject.hideNameInPrompt' "$THEMING_ROOT/dist/projects.json")" = "true" ]
}

@test "hideNameInPrompt is false in dist when absent in src" {
  bats_run_script "$PROJECTS_BUILD"
  [ "$(jq -r '.myproject.hideNameInPrompt' "$THEMING_ROOT/dist/projects.json")" = "false" ]
}

@test "path has trailing slash in dist" {
  bats_run_script "$PROJECTS_BUILD"
  local path_val
  path_val="$(jq -r '.myproject.path' "$THEMING_ROOT/dist/projects.json")"
  [[ "$path_val" == */ ]]
}

@test "dist/projects.zsh starts with typeset -gA PROJECTS" {
  bats_run_script "$PROJECTS_BUILD"
  local first_line
  first_line="$(head -1 "$THEMING_ROOT/dist/projects.zsh")"
  [ "$first_line" = "typeset -gA PROJECTS" ]
}

@test "dist/projects.zsh has dot-notation keys for background, backgroundInactive, foreground" {
  bats_run_script "$PROJECTS_BUILD"
  grep -q 'PROJECTS\[myproject\.background\.name\]' "$THEMING_ROOT/dist/projects.zsh"
  grep -q 'PROJECTS\[myproject\.background\.ansi\]' "$THEMING_ROOT/dist/projects.zsh"
  grep -q 'PROJECTS\[myproject\.background\.hex\]' "$THEMING_ROOT/dist/projects.zsh"
  grep -q 'PROJECTS\[myproject\.backgroundInactive\.name\]' "$THEMING_ROOT/dist/projects.zsh"
  grep -q 'PROJECTS\[myproject\.foreground\.name\]' "$THEMING_ROOT/dist/projects.zsh"
}

@test "dist/projects.zsh has path key" {
  bats_run_script "$PROJECTS_BUILD"
  grep -q 'PROJECTS\[myproject\.path\]' "$THEMING_ROOT/dist/projects.zsh"
}

@test "dist/projects.zsh has icon key" {
  bats_run_script "$PROJECTS_BUILD"
  grep -q 'PROJECTS\[myproject\.icon\]' "$THEMING_ROOT/dist/projects.zsh"
}

@test "dist/projects.zsh has hideNameInPrompt key" {
  bats_run_script "$PROJECTS_BUILD"
  grep -q 'PROJECTS\[myproject\.hideNameInPrompt\]' "$THEMING_ROOT/dist/projects.zsh"
}

@test "src/projects.json is sorted alphabetically after build" {
  cat > "$THEMING_ROOT/src/projects.json" << 'JSON'
{"zzz":{"icon":"Z"},"aaa":{"icon":"A"}}
JSON
  bats_run_script "$PROJECTS_BUILD"
  local first_key
  first_key="$(jq -r 'keys_unsorted[0]' "$THEMING_ROOT/src/projects.json")"
  [ "$first_key" = "aaa" ]
}
