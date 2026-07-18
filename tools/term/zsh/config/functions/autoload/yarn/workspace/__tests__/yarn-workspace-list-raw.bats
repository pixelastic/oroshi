bats_load_library 'helper'

setup() {
  bats_git_dir 'monorepo'
  bats_disable_worktree_aware

  # Root package.json with workspaces globs
  cat > "$BATS_GIT_DIR/package.json" <<'PKG'
{
  "name": "my-monorepo",
  "workspaces": ["modules/*"]
}
PKG

  # Two workspace modules
  mkdir -p "$BATS_GIT_DIR/modules/lib-a"
  cat > "$BATS_GIT_DIR/modules/lib-a/package.json" <<'PKG'
{
  "name": "@mono/lib-a",
  "description": "First library"
}
PKG

  mkdir -p "$BATS_GIT_DIR/modules/lib-b"
  cat > "$BATS_GIT_DIR/modules/lib-b/package.json" <<'PKG'
{
  "name": "@mono/lib-b",
  "description": "Second library"
}
PKG
}

# --- Output format ---

@test "each line has 3 ▮-separated fields" {
  bats_run_zsh "cd $BATS_GIT_DIR && yarn-workspace-list-raw"
  [ "$status" -eq 0 ]

  local lineCount=0
  while IFS= read -r line; do
    [[ "$line" == "" ]] && continue
    local fieldCount="$(echo "$line" | awk -F '▮' '{print NF}')"
    [ "$fieldCount" -eq 3 ]
    lineCount=$((lineCount + 1))
  done <<< "$output"
  [ "$lineCount" -eq 2 ]
}

# --- Workspace discovery ---

@test "discovers all workspace modules from globs" {
  bats_run_zsh "cd $BATS_GIT_DIR && yarn-workspace-list-raw"
  [ "$status" -eq 0 ]
  [[ "$output" == *"@mono/lib-a"* ]]
  [[ "$output" == *"@mono/lib-b"* ]]
}

@test "relative paths are relative to monorepo root" {
  bats_run_zsh "cd $BATS_GIT_DIR && yarn-workspace-list-raw"
  [ "$status" -eq 0 ]
  [[ "$output" == *"modules/lib-a"* ]]
  [[ "$output" == *"modules/lib-b"* ]]
}

@test "includes description from workspace package.json" {
  bats_run_zsh "cd $BATS_GIT_DIR && yarn-workspace-list-raw"
  [ "$status" -eq 0 ]
  [[ "$output" == *"First library"* ]]
  [[ "$output" == *"Second library"* ]]
}

@test "excludes workspace dirs without package.json" {
  # Dir matches glob but has no package.json
  mkdir -p "$BATS_GIT_DIR/modules/no-pkg"

  bats_run_zsh "cd $BATS_GIT_DIR && yarn-workspace-list-raw"
  [ "$status" -eq 0 ]
  [[ "$output" != *"no-pkg"* ]]
}

# --- Path argument ---

@test "works when given monorepo root path" {
  bats_run_zsh "yarn-workspace-list-raw $BATS_GIT_DIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"@mono/lib-a"* ]]
}

@test "works when given a sub-directory inside the monorepo" {
  bats_run_zsh "yarn-workspace-list-raw $BATS_GIT_DIR/modules/lib-a"
  [ "$status" -eq 0 ]
  [[ "$output" == *"@mono/lib-a"* ]]
  [[ "$output" == *"@mono/lib-b"* ]]
}

# --- Sorting ---

@test "sorts output by name" {
  mkdir -p "$BATS_GIT_DIR/modules/lib-z"
  cat > "$BATS_GIT_DIR/modules/lib-z/package.json" <<'PKG'
{
  "name": "@mono/zeta",
  "description": "Zeta library"
}
PKG

  bats_run_zsh "cd $BATS_GIT_DIR && yarn-workspace-list-raw"
  [ "$status" -eq 0 ]
  # lib-a must appear before zeta
  local aPos="${output%%@mono/lib-a*}"
  local zPos="${output%%@mono/zeta*}"
  [ "${#aPos}" -lt "${#zPos}" ]
}

@test "base name sorts before suffixed variants" {
  mkdir -p "$BATS_GIT_DIR/modules/lib-main"
  cat > "$BATS_GIT_DIR/modules/lib-main/package.json" <<'PKG'
{
  "name": "mylib",
  "description": "Main lib"
}
PKG

  mkdir -p "$BATS_GIT_DIR/modules/lib-ext"
  cat > "$BATS_GIT_DIR/modules/lib-ext/package.json" <<'PKG'
{
  "name": "mylib-extra",
  "description": "Extra lib"
}
PKG

  bats_run_zsh "cd $BATS_GIT_DIR && yarn-workspace-list-raw"
  [ "$status" -eq 0 ]
  local basePos="${output%%mylib▮*}"
  local suffixedPos="${output%%mylib-extra*}"
  [ "${#basePos}" -lt "${#suffixedPos}" ]
}

# --- Non-monorepo ---

@test "returns non-zero for non-monorepo path" {
  # Create a non-monorepo git repo
  local nonMono="$BATS_TMP_DIR/non-mono"
  mkdir -p "$nonMono"
  git -C "$nonMono" init --quiet
  git -C "$nonMono" commit --allow-empty --message "init" --quiet
  cat > "$nonMono/package.json" <<'PKG'
{
  "name": "solo-project"
}
PKG

  bats_run_zsh "yarn-workspace-list-raw $nonMono"
  [ "$status" -ne 0 ]
}
