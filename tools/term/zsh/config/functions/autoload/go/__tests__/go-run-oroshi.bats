bats_load_library 'helper'

setup() {
  bats_tmp_dir
  bats_disable_worktree_aware

  # Create a temporary mock command in the real scripts/src dir
  local srcDir="$OROSHI_ROOT/scripts/src/bats-test-build-pwd"
  mkdir -p "$srcDir/dist"

  # Build script records its pwd instead of calling go build
  cat > "$srcDir/build" <<'SCRIPT'
#!/usr/bin/env zsh
set -e
local binaryName="bats-test-build-pwd"
local srcDirectory="${OROSHI_ROOT}/scripts/src/${binaryName}"
pwd > "$srcDirectory/dist/recorded-pwd"
printf '#!/bin/sh\necho bats-ok' > "$srcDirectory/dist/$binaryName"
chmod +x "$srcDirectory/dist/$binaryName"
SCRIPT
  chmod +x "$srcDir/build"
  touch "$srcDir/main.go"

  # Non-Go directory to run from
  mkdir -p "$BATS_TMP_DIR/non-go-project"
  git -C "$BATS_TMP_DIR/non-go-project" init --initial-branch=main --quiet
}

teardown() {
  rm -rf "$OROSHI_ROOT/scripts/src/bats-test-build-pwd"
  bats_cleanup
}

@test "build runs from OROSHI_ROOT when PWD is outside the Go module" {
  bats_run_zsh "cd '$BATS_TMP_DIR/non-go-project' && go-run-oroshi bats-test-build-pwd"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"bats-ok"* ]]

  local recordedPwd
  recordedPwd="$(cat "$OROSHI_ROOT/scripts/src/bats-test-build-pwd/dist/recorded-pwd")"
  [[ "$recordedPwd" == "$OROSHI_ROOT" ]]
}
