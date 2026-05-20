bats_load_library 'helper'

setup() {
	bats_git_dir 'my-repo'
	bats_git_worktree 'fix/bug'
}

teardown() {
	bats_cleanup
}

# git_worktree_branch

@test "shows branch name inside a worktree" {
	cd "${BATS_GIT_WORKTREES}fix-bug"
	run zsh -c '
		source ~/.oroshi/config/term/zsh/zshenv.zsh
		source ~/.oroshi/config/term/zsh/prompt/git.zsh
		GIT_DIRECTORY_IS_REPOSITORY=1
		GIT_DIRECTORY_IS_WORKTREE=1
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_worktree_branch
		[[ "${OROSHI_PROMPT_PARTS[git_worktree_branch]}" != "" ]]
	'
	[ "$status" -eq 0 ]
}

@test "uses branch color regardless of ahead count" {
	cd "${BATS_GIT_WORKTREES}fix-bug"
	git commit --allow-empty -m "worktree commit"
	run zsh -c '
		source ~/.oroshi/config/term/zsh/zshenv.zsh
		source ~/.oroshi/config/term/zsh/theming/env/colors.zsh
		source ~/.oroshi/config/term/zsh/prompt/git.zsh
		GIT_DIRECTORY_IS_REPOSITORY=1
		GIT_DIRECTORY_IS_WORKTREE=1
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_worktree_branch
		result="${OROSHI_PROMPT_PARTS[git_worktree_branch]}"
		[[ "$result" == *"%F{$COLOR_ALIAS_GIT_BRANCH}"* ]]
	'
	[ "$status" -eq 0 ]
}

@test "git_branch is empty when inside a worktree" {
	cd "${BATS_GIT_WORKTREES}fix-bug"
	run zsh -c '
		source ~/.oroshi/config/term/zsh/zshenv.zsh
		source ~/.oroshi/config/term/zsh/prompt/git.zsh
		GIT_DIRECTORY_IS_REPOSITORY=1
		GIT_DIRECTORY_IS_WORKTREE=1
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_branch
		echo "${OROSHI_PROMPT_PARTS[git_branch]}"
	'
	[ "$status" -eq 0 ]
	[ "$output" = "" ]
}

@test "git_worktree_branch is empty outside a worktree" {
	cd "$BATS_GIT_DIR"
	run zsh -c '
		source ~/.oroshi/config/term/zsh/zshenv.zsh
		source ~/.oroshi/config/term/zsh/prompt/git.zsh
		GIT_DIRECTORY_IS_REPOSITORY=1
		GIT_DIRECTORY_IS_WORKTREE=0
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_worktree_branch
		echo "${OROSHI_PROMPT_PARTS[git_worktree_branch]}"
	'
	[ "$status" -eq 0 ]
	[ "$output" = "" ]
}

# git_worktree_distance

@test "shows ahead color and count when ahead" {
	cd "${BATS_GIT_WORKTREES}fix-bug"
	git commit --allow-empty -m "commit 1"
	git commit --allow-empty -m "commit 2"
	run zsh -c '
		source ~/.oroshi/config/term/zsh/zshenv.zsh
		source ~/.oroshi/config/term/zsh/theming/env/colors.zsh
		source ~/.oroshi/config/term/zsh/prompt/git.zsh
		GIT_DIRECTORY_IS_REPOSITORY=1
		GIT_DIRECTORY_IS_WORKTREE=1
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_worktree_distance
		result="${OROSHI_PROMPT_PARTS[git_worktree_distance]}"
		[[ "$result" == *"%F{$COLOR_ALIAS_GIT_AHEAD}"* ]] && [[ "$result" == *"2"* ]]
	'
	[ "$status" -eq 0 ]
}

@test "shows behind color and count when behind" {
	bats_git commit --allow-empty -m "main commit 1"
	bats_git commit --allow-empty -m "main commit 2"
	bats_git commit --allow-empty -m "main commit 3"
	cd "${BATS_GIT_WORKTREES}fix-bug"
	run zsh -c '
		source ~/.oroshi/config/term/zsh/zshenv.zsh
		source ~/.oroshi/config/term/zsh/theming/env/colors.zsh
		source ~/.oroshi/config/term/zsh/prompt/git.zsh
		GIT_DIRECTORY_IS_REPOSITORY=1
		GIT_DIRECTORY_IS_WORKTREE=1
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_worktree_distance
		result="${OROSHI_PROMPT_PARTS[git_worktree_distance]}"
		[[ "$result" == *"%F{$COLOR_ALIAS_GIT_BEHIND}"* ]] && [[ "$result" == *"3"* ]]
	'
	[ "$status" -eq 0 ]
}

@test "shows both colors when ahead and behind" {
	bats_git commit --allow-empty -m "main commit"
	cd "${BATS_GIT_WORKTREES}fix-bug"
	git commit --allow-empty -m "worktree commit"
	run zsh -c '
		source ~/.oroshi/config/term/zsh/zshenv.zsh
		source ~/.oroshi/config/term/zsh/theming/env/colors.zsh
		source ~/.oroshi/config/term/zsh/prompt/git.zsh
		GIT_DIRECTORY_IS_REPOSITORY=1
		GIT_DIRECTORY_IS_WORKTREE=1
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_worktree_distance
		result="${OROSHI_PROMPT_PARTS[git_worktree_distance]}"
		[[ "$result" == *"%F{$COLOR_ALIAS_GIT_AHEAD}"* ]] && [[ "$result" == *"%F{$COLOR_ALIAS_GIT_BEHIND}"* ]]
	'
	[ "$status" -eq 0 ]
}

@test "git_worktree_distance is empty when in sync with main" {
	cd "${BATS_GIT_WORKTREES}fix-bug"
	run zsh -c '
		source ~/.oroshi/config/term/zsh/zshenv.zsh
		source ~/.oroshi/config/term/zsh/prompt/git.zsh
		GIT_DIRECTORY_IS_REPOSITORY=1
		GIT_DIRECTORY_IS_WORKTREE=1
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_worktree_distance
		[[ "${OROSHI_PROMPT_PARTS[git_worktree_distance]}" == "" ]]
	'
	[ "$status" -eq 0 ]
}

@test "git_worktree_distance is empty outside a worktree" {
	cd "$BATS_GIT_DIR"
	run zsh -c '
		source ~/.oroshi/config/term/zsh/zshenv.zsh
		source ~/.oroshi/config/term/zsh/prompt/git.zsh
		GIT_DIRECTORY_IS_REPOSITORY=1
		GIT_DIRECTORY_IS_WORKTREE=0
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_worktree_distance
		[[ "${OROSHI_PROMPT_PARTS[git_worktree_distance]}" == "" ]]
	'
	[ "$status" -eq 0 ]
}
