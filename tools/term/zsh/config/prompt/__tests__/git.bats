bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
}

teardown() {
  bats_cleanup
}

# git_worktree_distance

@test "shows ahead color and count when ahead" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  git commit --allow-empty -m "commit 1"
  git commit --allow-empty -m "commit 2"
  local script="$BATS_TMP_DIR/git-prompt-1.zsh"
  cat >"$script" <<'ZSCRIPT'
		source ~/.oroshi/tools/term/zsh/config/zshenv.zsh
		source ~/.oroshi/tools/term/zsh/config/theming/env/colors.zsh
		source ~/.oroshi/tools/term/zsh/config/prompt/git.zsh
		GIT_DIRECTORY_IS_REPOSITORY=1
		GIT_DIRECTORY_IS_WORKTREE=1
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_worktree_distance
		result="${OROSHI_PROMPT_PARTS[git_worktree_distance]}"
		[[ "$result" == *"%F{$COLOR_ALIAS_GIT_AHEAD}"* ]] && [[ "$result" == *"2"* ]]
ZSCRIPT
  bats_run_zsh "$script"
  [ "$status" -eq 0 ]
}

@test "shows behind color and count when behind" {
  bats_git commit --allow-empty -m "main commit 1"
  bats_git commit --allow-empty -m "main commit 2"
  bats_git commit --allow-empty -m "main commit 3"
  cd "${BATS_GIT_WORKTREES}fix-bug"
  local script="$BATS_TMP_DIR/git-prompt-2.zsh"
  cat >"$script" <<'ZSCRIPT'
		source ~/.oroshi/tools/term/zsh/config/zshenv.zsh
		source ~/.oroshi/tools/term/zsh/config/theming/env/colors.zsh
		source ~/.oroshi/tools/term/zsh/config/prompt/git.zsh
		GIT_DIRECTORY_IS_REPOSITORY=1
		GIT_DIRECTORY_IS_WORKTREE=1
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_worktree_distance
		result="${OROSHI_PROMPT_PARTS[git_worktree_distance]}"
		[[ "$result" == *"%F{$COLOR_ALIAS_GIT_BEHIND}"* ]] && [[ "$result" == *"3"* ]]
ZSCRIPT
  bats_run_zsh "$script"
  [ "$status" -eq 0 ]
}

@test "shows both colors when ahead and behind" {
  bats_git commit --allow-empty -m "main commit"
  cd "${BATS_GIT_WORKTREES}fix-bug"
  git commit --allow-empty -m "worktree commit"
  local script="$BATS_TMP_DIR/git-prompt-3.zsh"
  cat >"$script" <<'ZSCRIPT'
		source ~/.oroshi/tools/term/zsh/config/zshenv.zsh
		source ~/.oroshi/tools/term/zsh/config/theming/env/colors.zsh
		source ~/.oroshi/tools/term/zsh/config/prompt/git.zsh
		GIT_DIRECTORY_IS_REPOSITORY=1
		GIT_DIRECTORY_IS_WORKTREE=1
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_worktree_distance
		result="${OROSHI_PROMPT_PARTS[git_worktree_distance]}"
		[[ "$result" == *"%F{$COLOR_ALIAS_GIT_AHEAD}"* ]] && [[ "$result" == *"%F{$COLOR_ALIAS_GIT_BEHIND}"* ]]
ZSCRIPT
  bats_run_zsh "$script"
  [ "$status" -eq 0 ]
}

@test "git_worktree_distance is empty when in sync with main" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  local script="$BATS_TMP_DIR/git-prompt-4.zsh"
  cat >"$script" <<'ZSCRIPT'
		source ~/.oroshi/tools/term/zsh/config/zshenv.zsh
		source ~/.oroshi/tools/term/zsh/config/prompt/git.zsh
		GIT_DIRECTORY_IS_REPOSITORY=1
		GIT_DIRECTORY_IS_WORKTREE=1
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_worktree_distance
		[[ "${OROSHI_PROMPT_PARTS[git_worktree_distance]}" == "" ]]
ZSCRIPT
  bats_run_zsh "$script"
  [ "$status" -eq 0 ]
}

@test "git_worktree_distance is empty outside a worktree" {
  cd "$BATS_GIT_DIR"
  local script="$BATS_TMP_DIR/git-prompt-5.zsh"
  cat >"$script" <<'ZSCRIPT'
		source ~/.oroshi/tools/term/zsh/config/zshenv.zsh
		source ~/.oroshi/tools/term/zsh/config/prompt/git.zsh
		GIT_DIRECTORY_IS_REPOSITORY=1
		GIT_DIRECTORY_IS_WORKTREE=0
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_worktree_distance
		[[ "${OROSHI_PROMPT_PARTS[git_worktree_distance]}" == "" ]]
ZSCRIPT
  bats_run_zsh "$script"
  [ "$status" -eq 0 ]
}

# git_issues_github

@test "git_issues_github is empty inside a worktree" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  local script="$BATS_TMP_DIR/git-prompt-6.zsh"
  cat >"$script" <<'ZSCRIPT'
		source ~/.oroshi/tools/term/zsh/config/zshenv.zsh
		source $ZSH_CONFIG_PATH/prompt/git.zsh
		GIT_DIRECTORY_IS_REPOSITORY=1
		GIT_DIRECTORY_IS_WORKTREE=1
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_issues_github
		echo "${OROSHI_PROMPT_PARTS[git_issues_github]}"
ZSCRIPT
  bats_run_zsh "$script"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

# git_plan_progress

@test "git_plan_progress is empty when not in a git repository" {
  local script="$BATS_TMP_DIR/git-prompt-7.zsh"
  cat >"$script" <<'ZSCRIPT'
		source ~/.oroshi/tools/term/zsh/config/zshenv.zsh
		source $ZSH_CONFIG_PATH/prompt/git.zsh
		GIT_DIRECTORY_IS_REPOSITORY=0
		GIT_DIRECTORY_IS_WORKTREE=0
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_plan_progress
		echo "${OROSHI_PROMPT_PARTS[git_plan_progress]}"
ZSCRIPT
  bats_run_zsh "$script"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "git_plan_progress is empty when not in a worktree" {
  cd "$BATS_GIT_DIR"
  local script="$BATS_TMP_DIR/git-prompt-8.zsh"
  cat >"$script" <<'ZSCRIPT'
		source ~/.oroshi/tools/term/zsh/config/zshenv.zsh
		source $ZSH_CONFIG_PATH/prompt/git.zsh
		GIT_DIRECTORY_IS_REPOSITORY=1
		GIT_DIRECTORY_IS_WORKTREE=0
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_plan_progress
		echo "${OROSHI_PROMPT_PARTS[git_plan_progress]}"
ZSCRIPT
  bats_run_zsh "$script"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "git_plan_progress is empty in a worktree without prd.json" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  local script="$BATS_TMP_DIR/git-prompt-9.zsh"
  cat >"$script" <<'ZSCRIPT'
		source ~/.oroshi/tools/term/zsh/config/zshenv.zsh
		source $ZSH_CONFIG_PATH/prompt/git.zsh
		GIT_DIRECTORY_IS_REPOSITORY=1
		GIT_DIRECTORY_IS_WORKTREE=1
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_plan_progress
		echo "${OROSHI_PROMPT_PARTS[git_plan_progress]}"
ZSCRIPT
  bats_run_zsh "$script"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "git_plan_progress shows yellow progress when issues in progress" {
  local wt_path="$(bats_git_worktree 'feat/my-prd')"
  mkdir -p "$wt_path/plans/feat_my-prd"
  printf '[{"id":"01","issue":"i.md","done":true,"blocked_by":[]},{"id":"02","issue":"i.md","done":false,"blocked_by":[]}]' >"$wt_path/plans/feat_my-prd/state.json"
  cd "$wt_path"
  local script="$BATS_TMP_DIR/git-prompt-10.zsh"
  cat >"$script" <<'ZSCRIPT'
		source ~/.oroshi/tools/term/zsh/config/zshenv.zsh
		source $ZSH_CONFIG_PATH/theming/env/colors.zsh
		source $ZSH_CONFIG_PATH/prompt/git.zsh
		GIT_DIRECTORY_IS_REPOSITORY=1
		GIT_DIRECTORY_IS_WORKTREE=1
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_plan_progress
		result="${OROSHI_PROMPT_PARTS[git_plan_progress]}"
		[[ "$result" == *"%F{$COLOR_ALIAS_GIT_ISSUE}"* ]] && echo "ok"
ZSCRIPT
  bats_run_zsh "$script"
  [ "$status" -eq 0 ]
  [ "$output" = "ok" ]
}

@test "git_plan_progress shows green progress when all issues complete" {
  local wt_path="$(bats_git_worktree 'feat/all-done')"
  mkdir -p "$wt_path/plans/feat_all-done"
  printf '[{"id":"01","issue":"i.md","done":true,"blocked_by":[]},{"id":"02","issue":"i.md","done":true,"blocked_by":[]}]' >"$wt_path/plans/feat_all-done/state.json"
  cd "$wt_path"
  local script="$BATS_TMP_DIR/git-prompt-11.zsh"
  cat >"$script" <<'ZSCRIPT'
		source ~/.oroshi/tools/term/zsh/config/zshenv.zsh
		source $ZSH_CONFIG_PATH/theming/env/colors.zsh
		source $ZSH_CONFIG_PATH/prompt/git.zsh
		GIT_DIRECTORY_IS_REPOSITORY=1
		GIT_DIRECTORY_IS_WORKTREE=1
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_plan_progress
		result="${OROSHI_PROMPT_PARTS[git_plan_progress]}"
		[[ "$result" == *"%F{$COLOR_ALIAS_SUCCESS}"* ]] && echo "ok"
ZSCRIPT
  bats_run_zsh "$script"
  [ "$status" -eq 0 ]
  [ "$output" = "ok" ]
}

@test "git_plan_progress shows error icon for malformed state.json" {
  local wt_path="$(bats_git_worktree 'feat/bad-json')"
  mkdir -p "$wt_path/plans/feat_bad-json"
  printf 'NOT VALID JSON' >"$wt_path/plans/feat_bad-json/state.json"
  cd "$wt_path"
  local script="$BATS_TMP_DIR/git-prompt-12.zsh"
  cat >"$script" <<'ZSCRIPT'
		source ~/.oroshi/tools/term/zsh/config/zshenv.zsh
		source $ZSH_CONFIG_PATH/theming/env/colors.zsh
		source $ZSH_CONFIG_PATH/prompt/git.zsh
		GIT_DIRECTORY_IS_REPOSITORY=1
		GIT_DIRECTORY_IS_WORKTREE=1
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_plan_progress
		result="${OROSHI_PROMPT_PARTS[git_plan_progress]}"
		[[ "$result" == *"%F{$COLOR_ALIAS_ERROR}"* ]] && echo "ok"
ZSCRIPT
  bats_run_zsh "$script"
  [ "$status" -eq 0 ]
  [ "$output" = "ok" ]
}
