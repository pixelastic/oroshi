bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'feature'

  # Source the ralph-single.zsh before each command
  sourcePrefix="source '$BATS_TEST_DIRNAME/../git.zsh'"
}

# git_issues_github

@test "git_issues_github is empty inside a worktree" {
  local script="$BATS_TMP_DIR/git-prompt-6.zsh"
  cat >"$script" <<'ZSCRIPT'
		source $OROSHI_ROOT/tools/term/zsh/config/prompt/git.zsh
		GIT_DIRECTORY_IS_REPOSITORY=1
		GIT_DIRECTORY_IS_WORKTREE=1
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_issues_github
		echo "${OROSHI_PROMPT_PARTS[git_issues_github]}"
ZSCRIPT
  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--feature && source $script"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

# git_plan_progress

@test "git_plan_progress is empty when not in a git repository" {
  local script="$BATS_TMP_DIR/git-prompt-7.zsh"
  cat >"$script" <<'ZSCRIPT'
		source $OROSHI_ROOT/tools/term/zsh/config/prompt/git.zsh
		GIT_DIRECTORY_IS_REPOSITORY=0
		GIT_DIRECTORY_IS_WORKTREE=0
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_plan_progress
		echo "${OROSHI_PROMPT_PARTS[git_plan_progress]}"
ZSCRIPT
  bats_run_zsh "source $script"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "git_plan_progress is empty when not in a worktree" {
  local script="$BATS_TMP_DIR/git-prompt-8.zsh"
  cat >"$script" <<'ZSCRIPT'
		source $OROSHI_ROOT/tools/term/zsh/config/prompt/git.zsh
		GIT_DIRECTORY_IS_REPOSITORY=1
		GIT_DIRECTORY_IS_WORKTREE=0
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_plan_progress
		echo "${OROSHI_PROMPT_PARTS[git_plan_progress]}"
ZSCRIPT
  bats_run_zsh "cd $BATS_GIT_DIR && source $script"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "git_plan_progress is empty in a worktree without prd.json" {
  local script="$BATS_TMP_DIR/git-prompt-9.zsh"
  cat >"$script" <<'ZSCRIPT'
		source $OROSHI_ROOT/tools/term/zsh/config/prompt/git.zsh
		GIT_DIRECTORY_IS_REPOSITORY=1
		GIT_DIRECTORY_IS_WORKTREE=1
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_plan_progress
		echo "${OROSHI_PROMPT_PARTS[git_plan_progress]}"
ZSCRIPT
  bats_run_zsh "cd ${BATS_GIT_WORKTREES}my-repo--feature && source $script"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

