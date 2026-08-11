bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "converts export lines to JSON" {
  cat > "$BATS_TMP_DIR/env.zsh" << 'EOF'
export FOO="bar"
export BAZ="qux"
EOF

  bats_run_zsh "zsh2json $BATS_TMP_DIR/env.zsh"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/env.json" ]]

  local content
  content="$(cat "$BATS_TMP_DIR/env.json")"
  [[ "$content" == *'"FOO": "bar"'* ]]
  [[ "$content" == *'"BAZ": "qux"'* ]]
}

@test "skips empty lines" {
  cat > "$BATS_TMP_DIR/env.zsh" << 'EOF'
export KEY="value"

export OTHER="data"
EOF

  bats_run_zsh "zsh2json $BATS_TMP_DIR/env.zsh"
  [[ "$status" -eq 0 ]]

  local content
  content="$(cat "$BATS_TMP_DIR/env.json")"
  [[ "$content" == *'"KEY": "value"'* ]]
  [[ "$content" == *'"OTHER": "data"'* ]]
}

@test "output is valid JSON" {
  cat > "$BATS_TMP_DIR/env.zsh" << 'EOF'
export SINGLE="val"
EOF

  bats_run_zsh "zsh2json $BATS_TMP_DIR/env.zsh"
  jq '.' "$BATS_TMP_DIR/env.json" > /dev/null 2>&1
}
