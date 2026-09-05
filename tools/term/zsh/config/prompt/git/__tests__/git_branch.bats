bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "git_branch is empty when not in a git repository" {
  local script="$BATS_TMP_DIR/git-branch-1.zsh"
  cat >"$script" <<'ZSCRIPT'
		source $OROSHI_ROOT/tools/term/zsh/config/prompt/git/git_branch.zsh
		GIT_DIRECTORY_IS_REPOSITORY=0
		GIT_DIRECTORY_IS_WORKTREE=0
		GIT_DIRECTORY_IS_SUBMODULE=0
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_branch
		echo "${OROSHI_PROMPT_PARTS[git_branch]}"
ZSCRIPT
  bats_run_zsh "source $script"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

@test "git_branch is empty when in a worktree (branch shown on left via context-badge)" {
  local script="$BATS_TMP_DIR/git-branch-2.zsh"
  cat >"$script" <<'ZSCRIPT'
		source $OROSHI_ROOT/tools/term/zsh/config/prompt/git/git_branch.zsh
		GIT_DIRECTORY_IS_REPOSITORY=1
		GIT_DIRECTORY_IS_WORKTREE=1
		GIT_DIRECTORY_IS_SUBMODULE=0
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_branch
		echo "${OROSHI_PROMPT_PARTS[git_branch]}"
ZSCRIPT
  bats_run_zsh "source $script"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

@test "git_branch shows branch in a submodule inside a worktree" {
  local script="$BATS_TMP_DIR/git-branch-3.zsh"
  cat >"$script" <<'ZSCRIPT'
		source $OROSHI_ROOT/tools/term/zsh/config/prompt/git/git_branch.zsh
		function git-branch-colorize() { echo "mocked-branch" }
		GIT_DIRECTORY_IS_REPOSITORY=1
		GIT_DIRECTORY_IS_WORKTREE=1
		GIT_DIRECTORY_IS_SUBMODULE=1
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_branch
		echo "${OROSHI_PROMPT_PARTS[git_branch]}"
ZSCRIPT
  bats_run_zsh "source $script"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "mocked-branch" ]]
}

@test "git_branch shows branch in a regular repo (not worktree)" {
  local script="$BATS_TMP_DIR/git-branch-4.zsh"
  cat >"$script" <<'ZSCRIPT'
		source $OROSHI_ROOT/tools/term/zsh/config/prompt/git/git_branch.zsh
		function git-branch-colorize() { echo "main-branch" }
		GIT_DIRECTORY_IS_REPOSITORY=1
		GIT_DIRECTORY_IS_WORKTREE=0
		GIT_DIRECTORY_IS_SUBMODULE=0
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_branch
		echo "${OROSHI_PROMPT_PARTS[git_branch]}"
ZSCRIPT
  bats_run_zsh "source $script"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "main-branch" ]]
}
