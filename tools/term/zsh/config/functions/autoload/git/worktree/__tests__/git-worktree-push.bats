bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
  cd "${BATS_GIT_WORKTREES}my-repo--fix-bug" || return 1
  git commit --allow-empty --quiet -m "fix work"
}

@test "fast-forwards main to current HEAD" {
  cd "${BATS_GIT_WORKTREES}my-repo--fix-bug"
  local fixHead="$(git rev-parse HEAD)"
  bats_run_zsh "git-worktree-push"
  [[ "$status" -eq 0 ]]
  run bats_git rev-parse main
  [[ "$output" = "$fixHead" ]]
}

@test "calls git-dependencies-update with --repo mainPath and pre-merge HEAD" {
  git-dependencies-update() { echo "$@" >> "$BATS_TMP_DIR/dep-update-calls"; }
  bats_mock git-dependencies-update
  bats_disable_worktree_aware

  cd "${BATS_GIT_WORKTREES}my-repo--fix-bug"
  local mainPath="$BATS_GIT_DIR"
  local preMergeHead="$(git -C "$mainPath" rev-parse HEAD)"
  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--fix-bug && git-worktree-push"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/dep-update-calls")" == "--repo $mainPath $preMergeHead --async" ]]
}

@test "echoes status lines before each step" {
  git-dependencies-update() { :; }
  bats_mock git-dependencies-update
  bats_disable_worktree_aware

  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--fix-bug && git-worktree-push"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"Checking submodules..."* ]]
  [[ "$output" == *"Merging into main..."* ]]
  [[ "$output" == *"Updating dependencies..."* ]]
}

@test "uses git-branch-push-pretty and echoes Pushing for changed submodule" {
  # Fresh repo with submodule + worktree
  bats_git_dir 'sub-repo'
  bats_git_submodule "$BATS_GIT_DIR" 'my-sub'
  bats_git_worktree 'fix/bug'
  local worktree="${BATS_GIT_WORKTREES}sub-repo--fix-bug"

  # Advance submodule pointer in worktree so it differs from main
  local upstream="$BATS_TMP_DIR/sub-upstream-my-sub"
  git -C "$upstream" commit --allow-empty --quiet -m "advance"
  local newHash="$(git -C "$upstream" rev-parse HEAD)"
  git -C "$worktree" update-index --cacheinfo "160000,$newHash,my-sub"
  git -C "$worktree" commit --quiet -m "update sub pointer"

  # Mock collaborators
  git-worktree-submodule-preflight() { return 0; }
  git-branch-push-pretty() { echo "$@" >> "$BATS_TMP_DIR/pretty-push-calls"; }
  git-branch-push() {
    echo "WRONG: plain push called" >> "$BATS_TMP_DIR/plain-push-calls"
  }
  git-dependencies-update() { :; }
  git-submodule-list-raw() { echo "my-sub▮abc12345▮main"; }
  bats_mock git-worktree-submodule-preflight git-branch-push-pretty git-branch-push git-dependencies-update git-submodule-list-raw
  bats_disable_worktree_aware

  bats_run_zsh "cd $worktree && git-worktree-push"
  [[ "$status" -eq 0 ]]
  # git-branch-push-pretty was called, not git-branch-push
  [[ -f "$BATS_TMP_DIR/pretty-push-calls" ]]
  [[ ! -f "$BATS_TMP_DIR/plain-push-calls" ]]
  [[ "$(cat "$BATS_TMP_DIR/pretty-push-calls")" == *"--repo"*"my-sub"* ]]
  # Status line for the submodule push
  [[ "$output" == *"Pushing my-sub..."* ]]
}

@test "returns 1 if history has diverged" {
  cd "$BATS_GIT_DIR"
  git commit --allow-empty -m "main work"
  cd "${BATS_GIT_WORKTREES}my-repo--fix-bug"
  bats_run_zsh "git-worktree-push"
  [[ "$status" -ne 0 ]]
}

@test "aborts if preflight fails, merge never happens" {
  git-worktree-submodule-preflight() {
    echo "my-sub has uncommitted changes"
    return 1
  }
  git-dependencies-update() { :; }
  bats_mock git-worktree-submodule-preflight git-dependencies-update
  bats_disable_worktree_aware

  local mainHeadBefore="$(git -C "$BATS_GIT_DIR" rev-parse HEAD)"

  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--fix-bug && git-worktree-push"
  [[ "$status" -ne 0 ]]
  [[ "$output" != "" ]]

  # Main HEAD unchanged — merge never ran
  local mainHeadAfter="$(git -C "$BATS_GIT_DIR" rev-parse HEAD)"
  [[ "$mainHeadBefore" == "$mainHeadAfter" ]]
}

@test "pushes changed submodule to remote before merge" {
  # Fresh repo with submodule + worktree
  bats_git_dir 'sub-repo'
  bats_git_submodule "$BATS_GIT_DIR" 'my-sub'
  bats_git_worktree 'fix/bug'
  local worktree="${BATS_GIT_WORKTREES}sub-repo--fix-bug"

  # Advance submodule pointer in worktree so it differs from main
  local upstream="$BATS_TMP_DIR/sub-upstream-my-sub"
  git -C "$upstream" commit --allow-empty --quiet -m "advance"
  local newHash="$(git -C "$upstream" rev-parse HEAD)"
  git -C "$worktree" update-index --cacheinfo "160000,$newHash,my-sub"
  git -C "$worktree" commit --quiet -m "update sub pointer"

  # Mock collaborators
  git-worktree-submodule-preflight() { return 0; }
  git-branch-push-pretty() { echo "$@" >> "$BATS_TMP_DIR/push-calls"; }
  git-dependencies-update() { :; }
  git-submodule-list-raw() { echo "my-sub▮abc12345▮main"; }
  bats_mock git-worktree-submodule-preflight git-branch-push-pretty git-dependencies-update git-submodule-list-raw
  bats_disable_worktree_aware

  bats_run_zsh "cd $worktree && git-worktree-push"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/push-calls" ]]
  [[ "$(cat "$BATS_TMP_DIR/push-calls")" == *"--repo"*"my-sub"* ]]
}

@test "calls colors-reload when color source files changed in oroshi worktree" {
  git-dependencies-update() { :; }
  git-worktree-is-oroshi() { return 0; }
  git-file-has-changed() { return 0; }
  colors-reload() { echo "colors-reload called" >> "$BATS_TMP_DIR/colors-calls"; }
  prose-build() { :; }
  bats_mock git-dependencies-update git-worktree-is-oroshi git-file-has-changed colors-reload prose-build
  bats_disable_worktree_aware

  # Mock deploy script (also triggered when git-file-has-changed returns 0)
  mkdir -p "$BATS_GIT_DIR/tools/ai/claude"
  cat > "$BATS_GIT_DIR/tools/ai/claude/deploy" <<EOF
#!/usr/bin/env zsh
EOF
  chmod +x "$BATS_GIT_DIR/tools/ai/claude/deploy"

  # Mock extension reload script (also triggered when git-file-has-changed returns 0)
  mkdir -p "$BATS_GIT_DIR/tools/ubuntu/24.04/extensions/oroshi-statuses"
  cat > "$BATS_GIT_DIR/tools/ubuntu/24.04/extensions/oroshi-statuses/reload" <<'EOF'
#!/usr/bin/env zsh
EOF

  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--fix-bug && git-worktree-push"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/colors-calls" ]]
  [[ "$output" == *"Updating colors..."* ]]
}

@test "does not call colors-reload when no color files changed" {
  git-dependencies-update() { :; }
  git-worktree-is-oroshi() { return 0; }
  git-file-has-changed() { return 1; }
  colors-reload() { echo "colors-reload called" >> "$BATS_TMP_DIR/colors-calls"; }
  bats_mock git-dependencies-update git-worktree-is-oroshi git-file-has-changed colors-reload
  bats_disable_worktree_aware

  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--fix-bug && git-worktree-push"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/colors-calls" ]]
  [[ "$output" != *"Updating colors..."* ]]
}

@test "does not call colors-reload for a non-oroshi repo" {
  git-dependencies-update() { :; }
  git-worktree-is-oroshi() { return 1; }
  colors-reload() { echo "colors-reload called" >> "$BATS_TMP_DIR/colors-calls"; }
  bats_mock git-dependencies-update git-worktree-is-oroshi colors-reload
  bats_disable_worktree_aware

  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--fix-bug && git-worktree-push"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/colors-calls" ]]
}

@test "calls deploy when skill beacon files changed in oroshi worktree" {
  git-dependencies-update() { :; }
  git-worktree-is-oroshi() { return 0; }
  git-file-has-changed() { return 0; }
  colors-reload() { :; }
  prose-build() { :; }
  bats_mock git-dependencies-update git-worktree-is-oroshi git-file-has-changed colors-reload prose-build
  bats_disable_worktree_aware

  mkdir -p "$BATS_GIT_DIR/tools/ai/claude"
  cat > "$BATS_GIT_DIR/tools/ai/claude/deploy" <<EOF
#!/usr/bin/env zsh
echo "deploy called" >> "$BATS_TMP_DIR/deploy-calls"
EOF
  chmod +x "$BATS_GIT_DIR/tools/ai/claude/deploy"

  # Mock extension reload script (also triggered when git-file-has-changed returns 0)
  mkdir -p "$BATS_GIT_DIR/tools/ubuntu/24.04/extensions/oroshi-statuses"
  cat > "$BATS_GIT_DIR/tools/ubuntu/24.04/extensions/oroshi-statuses/reload" <<'EOF'
#!/usr/bin/env zsh
EOF

  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--fix-bug && git-worktree-push"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/deploy-calls" ]]
  [[ "$output" == *"Deploying skills..."* ]]
}

@test "does not call deploy when no skill files changed" {
  git-dependencies-update() { :; }
  git-worktree-is-oroshi() { return 0; }
  git-file-has-changed() { return 1; }
  colors-reload() { :; }
  bats_mock git-dependencies-update git-worktree-is-oroshi git-file-has-changed colors-reload
  bats_disable_worktree_aware

  mkdir -p "$BATS_GIT_DIR/tools/ai/claude"
  cat > "$BATS_GIT_DIR/tools/ai/claude/deploy" <<EOF
#!/usr/bin/env zsh
echo "deploy called" >> "$BATS_TMP_DIR/deploy-calls"
EOF
  chmod +x "$BATS_GIT_DIR/tools/ai/claude/deploy"

  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--fix-bug && git-worktree-push"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/deploy-calls" ]]
  [[ "$output" != *"Deploying skills..."* ]]
}

@test "does not call deploy for a non-oroshi repo" {
  git-dependencies-update() { :; }
  git-worktree-is-oroshi() { return 1; }
  bats_mock git-dependencies-update git-worktree-is-oroshi
  bats_disable_worktree_aware

  mkdir -p "$BATS_GIT_DIR/tools/ai/claude"
  cat > "$BATS_GIT_DIR/tools/ai/claude/deploy" <<EOF
#!/usr/bin/env zsh
echo "deploy called" >> "$BATS_TMP_DIR/deploy-calls"
EOF
  chmod +x "$BATS_GIT_DIR/tools/ai/claude/deploy"

  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--fix-bug && git-worktree-push"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/deploy-calls" ]]
}

@test "calls prose-build when prose source files changed in oroshi worktree" {
  git-dependencies-update() { :; }
  git-worktree-is-oroshi() { return 0; }
  git-file-has-changed() { return 0; }
  colors-reload() { :; }
  prose-build() { echo "OROSHI_ROOT=$OROSHI_ROOT" >> "$BATS_TMP_DIR/prose-build-calls"; }
  bats_mock git-dependencies-update git-worktree-is-oroshi git-file-has-changed colors-reload prose-build
  bats_disable_worktree_aware

  # Mock deploy script (also triggered when git-file-has-changed returns 0)
  mkdir -p "$BATS_GIT_DIR/tools/ai/claude"
  cat > "$BATS_GIT_DIR/tools/ai/claude/deploy" <<EOF
#!/usr/bin/env zsh
EOF
  chmod +x "$BATS_GIT_DIR/tools/ai/claude/deploy"

  # Mock extension reload script (also triggered when git-file-has-changed returns 0)
  mkdir -p "$BATS_GIT_DIR/tools/ubuntu/24.04/extensions/oroshi-statuses"
  cat > "$BATS_GIT_DIR/tools/ubuntu/24.04/extensions/oroshi-statuses/reload" <<'EOF'
#!/usr/bin/env zsh
EOF

  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--fix-bug && git-worktree-push"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/prose-build-calls" ]]
  [[ "$(cat "$BATS_TMP_DIR/prose-build-calls")" == "OROSHI_ROOT=$BATS_GIT_DIR" ]]
  [[ "$output" == *"Building prose..."* ]]
}

@test "does not call prose-build when no prose files changed" {
  git-dependencies-update() { :; }
  git-worktree-is-oroshi() { return 0; }
  git-file-has-changed() { return 1; }
  prose-build() { echo "called" >> "$BATS_TMP_DIR/prose-build-calls"; }
  bats_mock git-dependencies-update git-worktree-is-oroshi git-file-has-changed prose-build
  bats_disable_worktree_aware

  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--fix-bug && git-worktree-push"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/prose-build-calls" ]]
  [[ "$output" != *"Building prose..."* ]]
}

@test "does not call prose-build for a non-oroshi repo" {
  git-dependencies-update() { :; }
  git-worktree-is-oroshi() { return 1; }
  prose-build() { echo "called" >> "$BATS_TMP_DIR/prose-build-calls"; }
  bats_mock git-dependencies-update git-worktree-is-oroshi prose-build
  bats_disable_worktree_aware

  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--fix-bug && git-worktree-push"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/prose-build-calls" ]]
}

@test "calls git-commit-diffstat with pre-merge HEAD and --repo after merge" {
  git-dependencies-update() { :; }
  git-commit-diffstat() { echo "$@" >> "$BATS_TMP_DIR/diffstat-calls"; }
  bats_mock git-dependencies-update git-commit-diffstat
  bats_disable_worktree_aware

  local mainPath="$BATS_GIT_DIR"
  local preMergeHead="$(git -C "$mainPath" rev-parse HEAD)"

  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--fix-bug && git-worktree-push"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/diffstat-calls" ]]
  [[ "$(cat "$BATS_TMP_DIR/diffstat-calls")" == "$preMergeHead --repo $mainPath" ]]
}

@test "merge runs with --quiet flag" {
  git-dependencies-update() { :; }
  git-commit-diffstat() { :; }
  bats_mock git-dependencies-update git-commit-diffstat
  bats_disable_worktree_aware

  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--fix-bug && git-worktree-push"
  [[ "$status" -eq 0 ]]
  # Merge fast-forward summary (e.g. "Updating abc123..def456") should not appear
  [[ "$output" != *"Fast-forward"* ]]
}

@test "reloads GNOME extensions when extension source files changed in oroshi worktree" {
  git-dependencies-update() { :; }
  git-worktree-is-oroshi() { return 0; }
  git-file-has-changed() { return 0; }
  colors-reload() { :; }
  prose-build() { :; }
  gnome-extensions() { :; }
  bats_mock git-dependencies-update git-worktree-is-oroshi git-file-has-changed colors-reload prose-build gnome-extensions
  bats_disable_worktree_aware

  # Mock deploy script (also triggered when git-file-has-changed returns 0)
  mkdir -p "$BATS_GIT_DIR/tools/ai/claude"
  cat > "$BATS_GIT_DIR/tools/ai/claude/deploy" <<EOF
#!/usr/bin/env zsh
EOF
  chmod +x "$BATS_GIT_DIR/tools/ai/claude/deploy"

  # Mock reload script
  mkdir -p "$BATS_GIT_DIR/tools/ubuntu/24.04/extensions/oroshi-statuses"
  cat > "$BATS_GIT_DIR/tools/ubuntu/24.04/extensions/oroshi-statuses/reload" <<EOF
#!/usr/bin/env zsh
echo "reload called" >> "$BATS_TMP_DIR/reload-calls"
EOF

  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--fix-bug && git-worktree-push"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/reload-calls" ]]
  [[ "$output" == *"Reloading GNOME extensions..."* ]]
}

@test "does not reload GNOME extensions when no extension files changed" {
  git-dependencies-update() { :; }
  git-worktree-is-oroshi() { return 0; }
  git-file-has-changed() { return 1; }
  gnome-extensions() { :; }
  bats_mock git-dependencies-update git-worktree-is-oroshi git-file-has-changed gnome-extensions
  bats_disable_worktree_aware

  # Mock reload script
  mkdir -p "$BATS_GIT_DIR/tools/ubuntu/24.04/extensions/oroshi-statuses"
  cat > "$BATS_GIT_DIR/tools/ubuntu/24.04/extensions/oroshi-statuses/reload" <<EOF
#!/usr/bin/env zsh
echo "reload called" >> "$BATS_TMP_DIR/reload-calls"
EOF

  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--fix-bug && git-worktree-push"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/reload-calls" ]]
  [[ "$output" != *"Reloading GNOME extensions..."* ]]
}

@test "does not reload GNOME extensions for a non-oroshi repo" {
  git-dependencies-update() { :; }
  git-worktree-is-oroshi() { return 1; }
  gnome-extensions() { :; }
  bats_mock git-dependencies-update git-worktree-is-oroshi gnome-extensions
  bats_disable_worktree_aware

  # Mock reload script
  mkdir -p "$BATS_GIT_DIR/tools/ubuntu/24.04/extensions/oroshi-statuses"
  cat > "$BATS_GIT_DIR/tools/ubuntu/24.04/extensions/oroshi-statuses/reload" <<EOF
#!/usr/bin/env zsh
echo "reload called" >> "$BATS_TMP_DIR/reload-calls"
EOF

  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--fix-bug && git-worktree-push"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/reload-calls" ]]
}

@test "skips submodule push when pointers are identical" {
  # Fresh repo with submodule + worktree (same pointer in both)
  bats_git_dir 'sub-repo'
  bats_git_submodule "$BATS_GIT_DIR" 'my-sub'
  bats_git_worktree 'fix/bug'
  local worktree="${BATS_GIT_WORKTREES}sub-repo--fix-bug"
  git -C "$worktree" commit --allow-empty --quiet -m "fix work"

  # Mock collaborators
  git-worktree-submodule-preflight() { return 0; }
  git-branch-push-pretty() { echo "$@" >> "$BATS_TMP_DIR/push-calls"; }
  git-dependencies-update() { :; }
  git-submodule-list-raw() { echo "my-sub▮abc12345▮main"; }
  bats_mock git-worktree-submodule-preflight git-branch-push-pretty git-dependencies-update git-submodule-list-raw
  bats_disable_worktree_aware

  local mainHeadBefore="$(git -C "$BATS_GIT_DIR" rev-parse HEAD)"

  bats_run_zsh "cd $worktree && git-worktree-push"
  [[ "$status" -eq 0 ]]
  # git-branch-push-pretty should NOT have been called
  [[ ! -f "$BATS_TMP_DIR/push-calls" ]]
  # Merge still happened — main HEAD advanced
  local mainHeadAfter="$(git -C "$BATS_GIT_DIR" rev-parse HEAD)"
  [[ "$mainHeadBefore" != "$mainHeadAfter" ]]
}
