bats_load_library 'helper'

PROJECTS_BUILD="$(realpath "${BATS_TEST_DIRNAME}/../projects-build")"

setup() {
  bats_tmp_dir

  export THEMING_ROOT="$BATS_TMP_DIR/theming"
  mkdir -p "$THEMING_ROOT/src"
  mkdir -p "$THEMING_ROOT/dist"

  colors-load-definitions() {
    export COLOR_GREEN_8="78"
    export COLOR_GREEN_8_HEXA="#166534"
    export COLOR_DARK_GREEN="211"
    export COLOR_DARK_GREEN_HEXA="#0f1a0f"
    export COLOR_GRAY_9="139"
    export COLOR_GRAY_9_HEXA="#111827"
    export COLOR_GREEN="2"
    export COLOR_GREEN_HEXA="#38a169"
  }
  bats_mock colors-load-definitions

  # full: all fields, path with trailing slash, backgroundInactive from numeric suffix
  # hidden: hideNameInPrompt=true, no path
  # icononly: minimal, no background/foreground/path
  # nosuffix: backgroundInactive from non-numeric suffix (GREEN -> DARK_GREEN)
  jo -d. \
    full.background=GREEN_8 \
    full.foreground=GRAY_9 \
    full.icon=X \
    "full.path=~/projects/full" \
    hidden.background=GREEN_8 \
    hidden.foreground=GRAY_9 \
    hidden.icon=H \
    hidden.hideNameInPrompt=true \
    icononly.icon=I \
    nosuffix.background=GREEN \
    nosuffix.foreground=GRAY_9 \
    nosuffix.icon=G \
    >"$THEMING_ROOT/src/projects.json"
}

teardown() {
  bats_cleanup
}

# --- Source ---

@test "src/projects.json is sorted alphabetically in-place after build" {
  jo -d. \
    zzz.icon=Z \
    mmm.icon=M \
    aaa.icon=A \
    >"$THEMING_ROOT/src/projects.json"
  bats_run_script "$PROJECTS_BUILD"
  run jq -r 'keys_unsorted[]' "$THEMING_ROOT/src/projects.json"
  [ "${lines[0]}" = "aaa" ]
  [ "${lines[1]}" = "mmm" ]
  [ "${lines[2]}" = "zzz" ]
}

# --- JSON ---

@test "produces dist/projects.json" {
  bats_run_script "$PROJECTS_BUILD"
  [ "$status" -eq 0 ]
  [ -f "$THEMING_ROOT/dist/projects.json" ]
}

@test "dist/projects.json matches expected output" {
  bats_run_script "$PROJECTS_BUILD"
  local expected
  expected=$(
    cat <<'EXPECTED'
{
  "full": {
    "background": {
      "ansi": 78,
      "hex": "#166534",
      "name": "GREEN_8"
    },
    "backgroundInactive": {
      "ansi": 211,
      "hex": "#0f1a0f",
      "name": "DARK_GREEN"
    },
    "foreground": {
      "ansi": 139,
      "hex": "#111827",
      "name": "GRAY_9"
    },
    "hideNameInPrompt": false,
    "icon": "X",
    "path": "~/projects/full/"
  },
  "hidden": {
    "background": {
      "ansi": 78,
      "hex": "#166534",
      "name": "GREEN_8"
    },
    "backgroundInactive": {
      "ansi": 211,
      "hex": "#0f1a0f",
      "name": "DARK_GREEN"
    },
    "foreground": {
      "ansi": 139,
      "hex": "#111827",
      "name": "GRAY_9"
    },
    "hideNameInPrompt": true,
    "icon": "H",
    "path": ""
  },
  "icononly": {
    "hideNameInPrompt": false,
    "icon": "I",
    "path": ""
  },
  "nosuffix": {
    "background": {
      "ansi": 2,
      "hex": "#38a169",
      "name": "GREEN"
    },
    "backgroundInactive": {
      "ansi": 211,
      "hex": "#0f1a0f",
      "name": "DARK_GREEN"
    },
    "foreground": {
      "ansi": 139,
      "hex": "#111827",
      "name": "GRAY_9"
    },
    "hideNameInPrompt": false,
    "icon": "G",
    "path": ""
  }
}
EXPECTED
  )
  [ "$(cat "$THEMING_ROOT/dist/projects.json")" = "$expected" ]
}

# --- ZSH ---

@test "produces dist/projects.zsh" {
  bats_run_script "$PROJECTS_BUILD"
  [ "$status" -eq 0 ]
  [ -f "$THEMING_ROOT/dist/projects.zsh" ]
}

@test "dist/projects.zsh sets all values for a full project" {
  bats_run_script "$PROJECTS_BUILD"

  # We need to run zsh, not source the file directly as bats won't understand
  # zsh syntax if sourced here
  run zsh -c "
    source '${THEMING_ROOT}/dist/projects.zsh'
    echo \${PROJECTS_V2[full:background:name]}
    echo \${PROJECTS_V2[full:background:ansi]}
    echo \${PROJECTS_V2[full:background:hex]}
    echo \${PROJECTS_V2[full:backgroundInactive:name]}
    echo \${PROJECTS_V2[full:backgroundInactive:ansi]}
    echo \${PROJECTS_V2[full:backgroundInactive:hex]}
    echo \${PROJECTS_V2[full:foreground:name]}
    echo \${PROJECTS_V2[full:foreground:ansi]}
    echo \${PROJECTS_V2[full:foreground:hex]}
    echo \${PROJECTS_V2[full:icon]}
    echo \${PROJECTS_V2[full:path]}
    echo \${PROJECTS_V2[full:hideNameInPrompt]}
  "
  [ "${lines[0]}" = "GREEN_8" ]
  [ "${lines[1]}" = "78" ]
  [ "${lines[2]}" = "#166534" ]
  [ "${lines[3]}" = "DARK_GREEN" ]
  [ "${lines[4]}" = "211" ]
  [ "${lines[5]}" = "#0f1a0f" ]
  [ "${lines[6]}" = "GRAY_9" ]
  [ "${lines[7]}" = "139" ]
  [ "${lines[8]}" = "#111827" ]
  [ "${lines[9]}" = "X" ]
  [ "${lines[10]}" = "$HOME/projects/full/" ]
  [ "${lines[11]}" = "0" ]
}
