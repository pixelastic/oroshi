bats_load_library 'helper'

setup() {
  bats_tmp_dir

  THEMING_DIR="$BATS_TMP_DIR/tools/term/zsh/config/theming"
  mkdir -p "$THEMING_DIR/src"
  mkdir -p "$THEMING_DIR/dist"

  bats_mock_env OROSHI_ROOT "$BATS_TMP_DIR"

  jq -n '{
    "amber":    {"ansi": 145, "hex": "#d97706"},
    "yellow-6": {"ansi": 46,  "hex": "#b7791f"},
    "yellow":   {"ansi": 45,  "hex": "#d69e2e"}
  }' >"$THEMING_DIR/dist/colors.json"

  jq -n '{
    "filetype-text":   "T",
    "filetype-md":     "M",
    "filetype-image":  "I",
    "filetype-js":     "J",
    "filetype-script": "S"
  }' >"$THEMING_DIR/dist/icons.json"

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
  }' >"$THEMING_DIR/src/filetypes.jsonc"
}

@test "produces dist/filetypes.zsh" {
  bats_run_zsh "filetypes-build"
  [[ "$status" -eq 0 ]]
  [[ -f "$THEMING_DIR/dist/filetypes.zsh" ]]
}

@test "dist/filetypes.zsh contains disable-file comment" {
  bats_run_zsh "filetypes-build"
  run grep "# zsh-lint disable-file=commandTooLong" "$THEMING_DIR/dist/filetypes.zsh"
  [[ "$status" -eq 0 ]]
}

@test "extension entry: FILETYPES[md:color] resolves to amber ANSI code" {
  bats_run_zsh "filetypes-build"
  bats_run_zsh "source '${THEMING_DIR}/dist/filetypes.zsh' && echo \${FILETYPES[md:color]}"
  [[ "${lines[0]}" = "145" ]]
}

@test "extension entry: FILETYPES[md:pattern] set to *.md" {
  bats_run_zsh "filetypes-build"
  bats_run_zsh "source '${THEMING_DIR}/dist/filetypes.zsh' && echo \${FILETYPES[md:pattern]}"
  [[ "${lines[0]}" = "*.md" ]]
}

@test "extension entry: FILETYPES[md:group] set to group name" {
  bats_run_zsh "filetypes-build"
  bats_run_zsh "source '${THEMING_DIR}/dist/filetypes.zsh' && echo \${FILETYPES[md:group]}"
  [[ "${lines[0]}" = "text" ]]
}

@test "extension entry: FILETYPES[md:icon] resolved from icon override" {
  bats_run_zsh "filetypes-build"
  bats_run_zsh "source '${THEMING_DIR}/dist/filetypes.zsh' && echo \${FILETYPES[md:icon]}"
  [[ "${lines[0]}" = "M" ]]
}

@test "extension entry: FILETYPES[md:bold] set to 0 when not specified" {
  bats_run_zsh "filetypes-build"
  bats_run_zsh "source '${THEMING_DIR}/dist/filetypes.zsh' && echo \${FILETYPES[md:bold]}"
  [[ "${lines[0]}" = "0" ]]
}

@test "filename entry: FILETYPES[_gitignore:pattern] set to .gitignore" {
  bats_run_zsh "filetypes-build"
  bats_run_zsh "source '${THEMING_DIR}/dist/filetypes.zsh' && echo \${FILETYPES[_gitignore:pattern]}"
  [[ "${lines[0]}" = ".gitignore" ]]
}

@test "override: extension with color override uses override color" {
  bats_run_zsh "filetypes-build"
  bats_run_zsh "source '${THEMING_DIR}/dist/filetypes.zsh' && echo \${FILETYPES[js:color]}"
  [[ "${lines[0]}" = "45" ]]
}

@test "override: extension with icon override uses override icon" {
  bats_run_zsh "filetypes-build"
  bats_run_zsh "source '${THEMING_DIR}/dist/filetypes.zsh' && echo \${FILETYPES[js:icon]}"
  [[ "${lines[0]}" = "J" ]]
}

@test "group entry: FILETYPES[image:color] has resolved ANSI code" {
  bats_run_zsh "filetypes-build"
  bats_run_zsh "source '${THEMING_DIR}/dist/filetypes.zsh' && echo \${FILETYPES[image:color]}"
  [[ "${lines[0]}" = "46" ]]
}

@test "group entry: FILETYPES[image:icon] has resolved glyph" {
  bats_run_zsh "filetypes-build"
  bats_run_zsh "source '${THEMING_DIR}/dist/filetypes.zsh' && echo \${FILETYPES[image:icon]}"
  [[ "${lines[0]}" = "I" ]]
}

# --- JSON output ---

@test "produces dist/filetypes.json" {
  bats_run_zsh "filetypes-build"
  [[ "$status" -eq 0 ]]
  [[ -f "$THEMING_DIR/dist/filetypes.json" ]]
}

@test "generates both dist/filetypes.zsh and dist/filetypes.json in a single run" {
  bats_run_zsh "filetypes-build"
  [[ "$status" -eq 0 ]]
  [[ -f "$THEMING_DIR/dist/filetypes.zsh" ]]
  [[ -f "$THEMING_DIR/dist/filetypes.json" ]]
}

@test "dist/filetypes.json: group entry has resolved color object" {
  bats_run_zsh "filetypes-build"
  run jq -r '.image.color.name' "$THEMING_DIR/dist/filetypes.json"
  [[ "$output" = "yellow-6" ]]
  run jq -r '.image.color.ansi' "$THEMING_DIR/dist/filetypes.json"
  [[ "$output" = "46" ]]
  run jq -r '.image.color.hex' "$THEMING_DIR/dist/filetypes.json"
  [[ "$output" = "#b7791f" ]]
}

@test "dist/filetypes.json: group entry has resolved icon object" {
  bats_run_zsh "filetypes-build"
  run jq -r '.image.icon.name' "$THEMING_DIR/dist/filetypes.json"
  [[ "$output" = "filetype-image" ]]
  run jq -r '.image.icon.glyph' "$THEMING_DIR/dist/filetypes.json"
  [[ "$output" = "I" ]]
}

@test "dist/filetypes.json: group entry has no pattern or group fields" {
  bats_run_zsh "filetypes-build"
  run jq '.image | has("pattern")' "$THEMING_DIR/dist/filetypes.json"
  [[ "$output" = "false" ]]
  run jq '.image | has("group")' "$THEMING_DIR/dist/filetypes.json"
  [[ "$output" = "false" ]]
}

@test "dist/filetypes.json: extension entry has pattern and group" {
  bats_run_zsh "filetypes-build"
  run jq -r '.md.pattern' "$THEMING_DIR/dist/filetypes.json"
  [[ "$output" = "*.md" ]]
  run jq -r '.md.group' "$THEMING_DIR/dist/filetypes.json"
  [[ "$output" = "text" ]]
}

@test "dist/filetypes.json: extension with overrides uses override values" {
  bats_run_zsh "filetypes-build"
  run jq -r '.js.color.name' "$THEMING_DIR/dist/filetypes.json"
  [[ "$output" = "yellow" ]]
  run jq -r '.js.icon.name' "$THEMING_DIR/dist/filetypes.json"
  [[ "$output" = "filetype-js" ]]
}

@test "dist/filetypes.json: filename entry has literal pattern" {
  bats_run_zsh "filetypes-build"
  run jq -r '._gitignore.pattern' "$THEMING_DIR/dist/filetypes.json"
  [[ "$output" = ".gitignore" ]]
}

@test "dist/filetypes.json matches expected output" {
  bats_run_zsh "filetypes-build"
  local expected
  expected=$(cat <<'EXPECTED'
{
  "_gitignore": {
    "bold": false,
    "color": {
      "ansi": 145,
      "hex": "#d97706",
      "name": "amber"
    },
    "group": "text",
    "icon": {
      "glyph": "T",
      "name": "filetype-text"
    },
    "pattern": ".gitignore"
  },
  "image": {
    "bold": false,
    "color": {
      "ansi": 46,
      "hex": "#b7791f",
      "name": "yellow-6"
    },
    "icon": {
      "glyph": "I",
      "name": "filetype-image"
    }
  },
  "js": {
    "bold": false,
    "color": {
      "ansi": 45,
      "hex": "#d69e2e",
      "name": "yellow"
    },
    "group": "script",
    "icon": {
      "glyph": "J",
      "name": "filetype-js"
    },
    "pattern": "*.js"
  },
  "md": {
    "bold": false,
    "color": {
      "ansi": 145,
      "hex": "#d97706",
      "name": "amber"
    },
    "group": "text",
    "icon": {
      "glyph": "M",
      "name": "filetype-md"
    },
    "pattern": "*.md"
  },
  "png": {
    "bold": false,
    "color": {
      "ansi": 46,
      "hex": "#b7791f",
      "name": "yellow-6"
    },
    "group": "image",
    "icon": {
      "glyph": "I",
      "name": "filetype-image"
    },
    "pattern": "*.png"
  },
  "script": {
    "bold": false,
    "color": {
      "ansi": 145,
      "hex": "#d97706",
      "name": "amber"
    },
    "icon": {
      "glyph": "S",
      "name": "filetype-script"
    }
  },
  "text": {
    "bold": false,
    "color": {
      "ansi": 145,
      "hex": "#d97706",
      "name": "amber"
    },
    "icon": {
      "glyph": "T",
      "name": "filetype-text"
    }
  },
  "txt": {
    "bold": false,
    "color": {
      "ansi": 145,
      "hex": "#d97706",
      "name": "amber"
    },
    "group": "text",
    "icon": {
      "glyph": "T",
      "name": "filetype-text"
    },
    "pattern": "*.txt"
  }
}
EXPECTED
  )
  [[ "$(cat "$THEMING_DIR/dist/filetypes.json")" = "$expected" ]]
}
