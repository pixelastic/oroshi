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

@test "shows ahead color and count when ahead" {
	cd "$TMP_DIRECTORY/my-repo--fix_bug"
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
	cd "$TMP_DIRECTORY/my-repo"
	git commit --allow-empty -m "main commit 1"
	git commit --allow-empty -m "main commit 2"
	git commit --allow-empty -m "main commit 3"
	cd "$TMP_DIRECTORY/my-repo--fix_bug"
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
	cd "$TMP_DIRECTORY/my-repo"
	git commit --allow-empty -m "main commit"
	cd "$TMP_DIRECTORY/my-repo--fix_bug"
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

@test "is empty when in sync with main" {
	cd "$TMP_DIRECTORY/my-repo--fix_bug"
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

@test "is empty outside a worktree" {
	cd "$TMP_DIRECTORY/my-repo"
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
