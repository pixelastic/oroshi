bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  CURRENT="$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/git/file/git-file-lint"
  cd "$BATS_GIT_DIR" || return
}

teardown() {
  bats_cleanup
}

@test "shows formatted violations for a dirty ZSH file" {
  echo 'echo hello' > "$BATS_GIT_DIR/bad.zsh"
  bats_git add bad.zsh
  bats_git commit --quiet -m "add bad.zsh"
  echo 'local a b c' >> "$BATS_GIT_DIR/bad.zsh"

  bats_run_zsh "$CURRENT"
  [ "$status" -eq 1 ]
  [[ "$output" =~ bad.zsh ]]
  [[ "$output" =~ ": noGroupedLocals: " ]]
  [[ ! "$output" =~ "\"level\"" ]]
  [[ ! "$output" =~ ": warning" ]]
  [[ ! "$output" =~ ": error" ]]
}

@test "exits silently for a dirty ZSH file with no violations" {
  echo 'echo hello' > "$BATS_GIT_DIR/clean.zsh"
  bats_git add clean.zsh
  bats_git commit --quiet -m "add clean.zsh"
  echo 'echo world' >> "$BATS_GIT_DIR/clean.zsh"

  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "exits silently when only non-ZSH files are dirty" {
  echo 'console.log("hello")' > "$BATS_GIT_DIR/app.js"
  bats_git add app.js
  bats_git commit --quiet -m "add app.js"
  echo 'console.log("world")' >> "$BATS_GIT_DIR/app.js"

  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "exits 0 on a clean working tree" {
  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
}

@test "shows relative path, not absolute path" {
  echo 'echo hello' > "$BATS_GIT_DIR/bad.zsh"
  bats_git add bad.zsh
  bats_git commit --quiet -m "add bad.zsh"
  echo 'local a b c' >> "$BATS_GIT_DIR/bad.zsh"

  bats_run_zsh "$CURRENT"
  [ "$status" -eq 1 ]
  [[ "$output" =~ bad.zsh ]]
  [[ ! "$output" =~ $BATS_GIT_DIR ]]
}

@test "skips deleted ZSH files without error" {
  echo 'echo hello' > "$BATS_GIT_DIR/todelete.zsh"
  bats_git add todelete.zsh
  bats_git commit --quiet -m "add todelete.zsh"
  rm "$BATS_GIT_DIR/todelete.zsh"

  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "surfaces bats violations for a dirty bats file" {
  printf '#!/usr/bin/env bats\n@test "foo" { true; }\n' > "$BATS_GIT_DIR/bad.bats"
  bats_git add bad.bats
  bats_git commit --quiet -m "add bad.bats"
  printf 'run zsh -c "echo hello"\n' >> "$BATS_GIT_DIR/bad.bats"

  bats_run_zsh "$CURRENT"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "── BATS ──" ]]
  [[ "$output" =~ bad.bats ]]
  [[ "$output" =~ "noRunZsh" ]]
}

@test "shows zsh section header for zsh violations" {
  echo 'echo hello' > "$BATS_GIT_DIR/bad.zsh"
  bats_git add bad.zsh
  bats_git commit --quiet -m "add bad.zsh"
  echo 'local a b c' >> "$BATS_GIT_DIR/bad.zsh"

  bats_run_zsh "$CURRENT"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "── ZSH ──" ]]
}

@test "surfaces bats violations for a dirty extensionless file when is-bats returns true for it" {
  printf '#!/usr/bin/env bats\n@test "foo" { true; }\n' > "$BATS_GIT_DIR/helper"
  bats_git add helper
  bats_git commit --quiet -m "add helper"
  printf 'run zsh -c "echo hello"\n' >> "$BATS_GIT_DIR/helper"

  is-bats() { return 0; }
  bats_mock is-bats

  bats_run_zsh "$CURRENT"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "── BATS ──" ]]
  [[ "$output" =~ "helper" ]]
  [[ "$output" =~ "noRunZsh" ]]
}

@test "does not lint a dirty bats file when is-bats rejects it" {
  printf '#!/usr/bin/env bats\n@test "foo" { true; }\n' > "$BATS_GIT_DIR/bad.bats"
  bats_git add bad.bats
  bats_git commit --quiet -m "add bad.bats"
  printf 'run zsh -c "echo hello"\n' >> "$BATS_GIT_DIR/bad.bats"

  is-bats() { return 1; }
  bats_mock is-bats

  bats_run_zsh "$CURRENT"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "shows only bats section when zsh is clean and bats violates" {
  echo 'echo hello' > "$BATS_GIT_DIR/clean.zsh"
  bats_git add clean.zsh
  bats_git commit --quiet -m "add clean.zsh"
  echo 'echo world' >> "$BATS_GIT_DIR/clean.zsh"

  printf '#!/usr/bin/env bats\n@test "foo" { true; }\n' > "$BATS_GIT_DIR/bad.bats"
  bats_git add bad.bats
  bats_git commit --quiet -m "add bad.bats"
  printf 'run zsh -c "echo hello"\n' >> "$BATS_GIT_DIR/bad.bats"

  bats_run_zsh "$CURRENT"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "── BATS ──" ]]
  [[ ! "$output" =~ "── ZSH ──" ]]
}
