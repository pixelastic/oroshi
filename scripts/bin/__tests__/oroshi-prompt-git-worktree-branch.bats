load 'helper'

setup() {
	export TMP_DIRECTORY="$(bats_tmp)"
	git init "$TMP_DIRECTORY/my-repo"
	cd "$TMP_DIRECTORY/my-repo"
	git config user.email "test@test.com"
	git config user.name "Test"
	git commit --allow-empty -m "init"
	git worktree add "$TMP_DIRECTORY/my-repo--fix_bug" -b fix/bug
}

teardown() {
	rm -rf "$TMP_DIRECTORY"
}

@test "shows branch name inside a worktree" {
	cd "$TMP_DIRECTORY/my-repo--fix_bug"
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
	cd "$TMP_DIRECTORY/my-repo--fix_bug"
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
	cd "$TMP_DIRECTORY/my-repo--fix_bug"
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
	cd "$TMP_DIRECTORY/my-repo"
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
