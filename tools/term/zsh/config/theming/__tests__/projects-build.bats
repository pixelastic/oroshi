bats_load_library 'helper'

setup() {
  PROJECTS_BUILD="$(realpath "${BATS_TEST_DIRNAME}/../projects-build")"
  bats_tmp_dir

  export THEMING_ROOT="$BATS_TMP_DIR/theming"
  mkdir -p "$THEMING_ROOT/src"
  mkdir -p "$THEMING_ROOT/dist"

  jq -n '{
    "green-8":   {"ansi": 78,  "hex": "#166534"},
    "green-dark":{"ansi": 211, "hex": "#0f1a0f"},
    "gray-9":    {"ansi": 139, "hex": "#111827"},
    "green":     {"ansi": 2,   "hex": "#38a169"}
  }' >"$THEMING_ROOT/dist/colors.json"

  # full: all fields, path with trailing slash, backgroundInactive from numeric suffix
  # hidden: hideNameInPrompt=true, no path
  # icononly: minimal, no background/foreground/path
  # nosuffix: backgroundInactive from non-numeric suffix (green -> green-dark)
  jo -d. \
    full.background=green-8 \
    full.foreground=gray-9 \
    full.icon=X \
    "full.path=~/projects/full" \
    hidden.background=green-8 \
    hidden.foreground=gray-9 \
    hidden.icon=H \
    hidden.hideNameInPrompt=true \
    icononly.icon=I \
    nosuffix.background=green \
    nosuffix.foreground=gray-9 \
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
  bats_run_zsh "$PROJECTS_BUILD"
  run jq -r 'keys_unsorted[]' "$THEMING_ROOT/src/projects.json"
  [ "${lines[0]}" = "aaa" ]
  [ "${lines[1]}" = "mmm" ]
  [ "${lines[2]}" = "zzz" ]
}

# --- JSON ---

@test "produces dist/projects.json" {
  bats_run_zsh "$PROJECTS_BUILD"
  [ "$status" -eq 0 ]
  [ -f "$THEMING_ROOT/dist/projects.json" ]
}

@test "dist/projects.json matches expected output" {
  bats_run_zsh "$PROJECTS_BUILD"
  local expected
  expected=$(
    cat <<'EXPECTED'
{
  "full": {
    "background": {
      "ansi": 78,
      "hex": "#166534",
      "name": "green-8"
    },
    "backgroundInactive": {
      "ansi": 211,
      "hex": "#0f1a0f",
      "name": "green-dark"
    },
    "foreground": {
      "ansi": 139,
      "hex": "#111827",
      "name": "gray-9"
    },
    "hideNameInPrompt": false,
    "icon": "X",
    "path": "~/projects/full"
  },
  "hidden": {
    "background": {
      "ansi": 78,
      "hex": "#166534",
      "name": "green-8"
    },
    "backgroundInactive": {
      "ansi": 211,
      "hex": "#0f1a0f",
      "name": "green-dark"
    },
    "foreground": {
      "ansi": 139,
      "hex": "#111827",
      "name": "gray-9"
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
      "name": "green"
    },
    "backgroundInactive": {
      "ansi": 211,
      "hex": "#0f1a0f",
      "name": "green-dark"
    },
    "foreground": {
      "ansi": 139,
      "hex": "#111827",
      "name": "gray-9"
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

@test "backgroundInactive name uses familyname-dark format" {
  bats_run_zsh "$PROJECTS_BUILD"
  run jq -r '.full.backgroundInactive.name' "$THEMING_ROOT/dist/projects.json"
  [ "$output" = "green-dark" ]
}

@test "backgroundInactive name for project with orange background uses orange-dark" {
  jq -n '{
    "orange-6": {"ansi": 101, "hex": "#ea580c"},
    "orange-dark":{"ansi": 100, "hex": "#1a0a00"}
  }' >"$THEMING_ROOT/dist/colors.json"
  jo -d. \
    myproject.background=orange-6 \
    myproject.icon=O \
    >"$THEMING_ROOT/src/projects.json"
  bats_run_zsh "$PROJECTS_BUILD"
  run jq -r '.myproject.backgroundInactive.name' "$THEMING_ROOT/dist/projects.json"
  [ "$output" = "orange-dark" ]
}

# --- ZSH ---

@test "produces dist/projects.zsh" {
  bats_run_zsh "$PROJECTS_BUILD"
  [ "$status" -eq 0 ]
  [ -f "$THEMING_ROOT/dist/projects.zsh" ]
}

@test "dist/projects.zsh sets all values for a full project" {
  bats_run_zsh "$PROJECTS_BUILD"

  local script="$BATS_TMP_DIR/verify-zsh.zsh"
  cat >"$script" <<SCRIPT
source '${THEMING_ROOT}/dist/projects.zsh'
echo \${PROJECTS[full:background:name]}
echo \${PROJECTS[full:background:ansi]}
echo \${PROJECTS[full:background:hex]}
echo \${PROJECTS[full:backgroundInactive:name]}
echo \${PROJECTS[full:backgroundInactive:ansi]}
echo \${PROJECTS[full:backgroundInactive:hex]}
echo \${PROJECTS[full:foreground:name]}
echo \${PROJECTS[full:foreground:ansi]}
echo \${PROJECTS[full:foreground:hex]}
echo \${PROJECTS[full:icon]}
echo \${PROJECTS[full:path]}
echo \${PROJECTS[full:hideNameInPrompt]}
SCRIPT
  bats_run_zsh "$script"
  [ "${lines[0]}" = "green-8" ]
  [ "${lines[1]}" = "78" ]
  [ "${lines[2]}" = "#166534" ]
  [ "${lines[3]}" = "green-dark" ]
  [ "${lines[4]}" = "211" ]
  [ "${lines[5]}" = "#0f1a0f" ]
  [ "${lines[6]}" = "gray-9" ]
  [ "${lines[7]}" = "139" ]
  [ "${lines[8]}" = "#111827" ]
  [ "${lines[9]}" = "X" ]
  [ "${lines[10]}" = "$HOME/projects/full" ]
  [ "${lines[11]}" = "0" ]
}
