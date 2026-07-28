bats_load_library 'helper'

setup() {
  bats_tmp_dir

  PROJECTS_JSONC="$BATS_TMP_DIR/oroshi/tools/term/zsh/config/theming/src/projects.jsonc"
  mkdir -p "$(dirname "$PROJECTS_JSONC")"
}

@test "fails when no project name given" {
  bats_run_zsh "project-remove"
  [ "$status" -eq 1 ]
}

@test "removes entry and preserves surrounding comments" {
  cat > "$PROJECTS_JSONC" <<'EOF'
{
  // First project
  "alpha": {
    "icon": "A"
  },
  // To remove
  "beta": {
    "icon": "B"
  },
  // Last project
  "gamma": {
    "icon": "G"
  }
}
EOF

  bats_run_zsh "OROSHI_ROOT=$BATS_TMP_DIR/oroshi project-remove beta"
  [ "$status" -eq 0 ]

  local expected='{
  // First project
  "alpha": {
    "icon": "A"
  },
  // Last project
  "gamma": {
    "icon": "G"
  }
}'
  [ "$(cat "$PROJECTS_JSONC")" = "$expected" ]
}

@test "exits 0 when project does not exist (idempotent)" {
  cat > "$PROJECTS_JSONC" <<'EOF'
{
  "alpha": {
    "icon": "A"
  }
}
EOF

  bats_run_zsh "OROSHI_ROOT=$BATS_TMP_DIR/oroshi project-remove nonexistent"
  [ "$status" -eq 0 ]

  local expected='{
  "alpha": {
    "icon": "A"
  }
}'
  [ "$(cat "$PROJECTS_JSONC")" = "$expected" ]
}
