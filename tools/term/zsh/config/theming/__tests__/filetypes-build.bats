bats_load_library 'helper'

setup() {
  FILETYPES_BUILD="$(realpath "${BATS_TEST_DIRNAME}/../filetypes-build")"
  bats_tmp_dir

  export THEMING_ROOT="$BATS_TMP_DIR/theming"
  mkdir -p "$THEMING_ROOT/src"

  # Mock OROSHI_ROOT so colors-load-definitions and icons-load-definitions
  # source fixtures instead of the real files
  local oroshiRoot="$BATS_TMP_DIR/oroshi"
  bats_mock_env OROSHI_ROOT "$oroshiRoot"

  mkdir -p "$oroshiRoot/tools/term/zsh/config/theming/dist"
  cat >"$oroshiRoot/tools/term/zsh/config/theming/dist/colors.zsh" <<'COLORS'
typeset -gA COLORS
COLORS[amber]=145
COLORS[amber:hex]="#d97706"
COLORS[yellow-6]=46
COLORS[yellow-6:hex]="#b7791f"
COLORS[yellow]=45
COLORS[yellow:hex]="#d69e2e"
COLORS

  cat >"$oroshiRoot/tools/term/zsh/config/theming/icons.zsh" <<'ICONS'
typeset -gA ICONS
ICONS[filetype-text]="T"
ICONS[filetype-md]="M"
ICONS[filetype-image]="I"
ICONS[filetype-js]="J"
ICONS[filetype-script]="S"
ICONS

  # Minimal filetypes.json:
  #   text: amber/filetype-text; patterns: md (icon override), txt, .gitignore (filename)
  #   image: yellow-6/filetype-image; patterns: png
  #   script: amber/filetype-script; patterns: js (color+icon override)
  jq -n '{
    "image": {
      "color": "yellow-6",
      "icon": "filetype-image",
      "patterns": ["png"]
    },
    "script": {
      "color": "amber",
      "icon": "filetype-script",
      "patterns": [
        {"extension": "js", "color": "yellow", "icon": "filetype-js"}
      ]
    },
    "text": {
      "color": "amber",
      "icon": "filetype-text",
      "patterns": [
        {"extension": "md", "icon": "filetype-md"},
        "txt",
        {"filename": ".gitignore"}
      ]
    }
  }' >"$THEMING_ROOT/src/filetypes.jsonc"
}

teardown() {
  bats_cleanup
}

@test "produces dist/filetypes.zsh" {
  bats_run_zsh "$FILETYPES_BUILD"
  [ "$status" -eq 0 ]
  [ -f "$THEMING_ROOT/dist/filetypes.zsh" ]
}

@test "dist/filetypes.zsh starts with typeset -gA FILETYPES" {
  bats_run_zsh "$FILETYPES_BUILD"
  run head -1 "$THEMING_ROOT/dist/filetypes.zsh"
  [ "$output" = "typeset -gA FILETYPES" ]
}

@test "extension entry: FILETYPES[md:color] resolves to amber ANSI code" {
  bats_run_zsh "$FILETYPES_BUILD"
  bats_run_zsh "source '${THEMING_ROOT}/dist/filetypes.zsh' && echo \${FILETYPES[md:color]}"
  [ "${lines[0]}" = "145" ]
}

@test "extension entry: FILETYPES[md:pattern] set to *.md" {
  bats_run_zsh "$FILETYPES_BUILD"
  bats_run_zsh "source '${THEMING_ROOT}/dist/filetypes.zsh' && echo \${FILETYPES[md:pattern]}"
  [ "${lines[0]}" = "*.md" ]
}

@test "extension entry: FILETYPES[md:group] set to group name" {
  bats_run_zsh "$FILETYPES_BUILD"
  bats_run_zsh "source '${THEMING_ROOT}/dist/filetypes.zsh' && echo \${FILETYPES[md:group]}"
  [ "${lines[0]}" = "text" ]
}

@test "extension entry: FILETYPES[md:icon] resolved from icon override" {
  bats_run_zsh "$FILETYPES_BUILD"
  bats_run_zsh "source '${THEMING_ROOT}/dist/filetypes.zsh' && echo \${FILETYPES[md:icon]}"
  [ "${lines[0]}" = "M" ]
}

@test "extension entry: FILETYPES[md:bold] set to 0 when not specified" {
  bats_run_zsh "$FILETYPES_BUILD"
  bats_run_zsh "source '${THEMING_ROOT}/dist/filetypes.zsh' && echo \${FILETYPES[md:bold]}"
  [ "${lines[0]}" = "0" ]
}

@test "filename entry: FILETYPES[_gitignore:pattern] set to .gitignore" {
  bats_run_zsh "$FILETYPES_BUILD"
  bats_run_zsh "source '${THEMING_ROOT}/dist/filetypes.zsh' && echo \${FILETYPES[_gitignore:pattern]}"
  [ "${lines[0]}" = ".gitignore" ]
}

@test "override: extension with color override uses override color" {
  bats_run_zsh "$FILETYPES_BUILD"
  bats_run_zsh "source '${THEMING_ROOT}/dist/filetypes.zsh' && echo \${FILETYPES[js:color]}"
  [ "${lines[0]}" = "45" ]
}

@test "override: extension with icon override uses override icon" {
  bats_run_zsh "$FILETYPES_BUILD"
  bats_run_zsh "source '${THEMING_ROOT}/dist/filetypes.zsh' && echo \${FILETYPES[js:icon]}"
  [ "${lines[0]}" = "J" ]
}

@test "group entry: FILETYPES[image:color] has resolved ANSI code" {
  bats_run_zsh "$FILETYPES_BUILD"
  bats_run_zsh "source '${THEMING_ROOT}/dist/filetypes.zsh' && echo \${FILETYPES[image:color]}"
  [ "${lines[0]}" = "46" ]
}

@test "group entry: FILETYPES[image:icon] has resolved glyph" {
  bats_run_zsh "$FILETYPES_BUILD"
  bats_run_zsh "source '${THEMING_ROOT}/dist/filetypes.zsh' && echo \${FILETYPES[image:icon]}"
  [ "${lines[0]}" = "I" ]
}
