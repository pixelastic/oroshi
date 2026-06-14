bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

teardown() {
  bats_cleanup
}

@test "git_worktree_distance is empty when not in a git repository" {
  local script="$BATS_TMP_DIR/gwt-dist-1.zsh"
  cat >"$script" <<'ZSCRIPT'
		source $OROSHI_ROOT/tools/term/zsh/config/prompt/git/git_worktree_distance.zsh
		GIT_DIRECTORY_IS_REPOSITORY=0
		GIT_DIRECTORY_IS_WORKTREE=0
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_worktree_distance
		echo "${OROSHI_PROMPT_PARTS[git_worktree_distance]}"
ZSCRIPT
  bats_run_zsh "source $script"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "git_worktree_distance is empty when not in a worktree" {
  local script="$BATS_TMP_DIR/gwt-dist-2.zsh"
  cat >"$script" <<'ZSCRIPT'
		source $OROSHI_ROOT/tools/term/zsh/config/prompt/git/git_worktree_distance.zsh
		GIT_DIRECTORY_IS_REPOSITORY=1
		GIT_DIRECTORY_IS_WORKTREE=0
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_worktree_distance
		echo "${OROSHI_PROMPT_PARTS[git_worktree_distance]}"
ZSCRIPT
  bats_run_zsh "source $script"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "git_worktree_distance is empty when ahead and behind are both 0" {
  local script="$BATS_TMP_DIR/gwt-dist-3.zsh"
  cat >"$script" <<'ZSCRIPT'
		source $OROSHI_ROOT/tools/term/zsh/config/prompt/git/git_worktree_distance.zsh
		function colors-load-definitions() { typeset -gA COLORS; COLORS[git-ahead]="123"; COLORS[git-behind]="456" }
		function icons-load-definitions() { typeset -gA ICONS; ICONS[git-branch-ahead]="AHEAD"; ICONS[git-branch-behind]="BEHIND" }
		function git-worktree-distance-raw() { echo "0▮0" }
		GIT_DIRECTORY_IS_REPOSITORY=1
		GIT_DIRECTORY_IS_WORKTREE=1
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_worktree_distance
		echo "${OROSHI_PROMPT_PARTS[git_worktree_distance]}"
ZSCRIPT
  bats_run_zsh "source $script"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "git_worktree_distance shows only ahead when ahead=1 behind=0" {
  local script="$BATS_TMP_DIR/gwt-dist-4.zsh"
  cat >"$script" <<'ZSCRIPT'
		source $OROSHI_ROOT/tools/term/zsh/config/prompt/git/git_worktree_distance.zsh
		function colors-load-definitions() { typeset -gA COLORS; COLORS[git-ahead]="123"; COLORS[git-behind]="456" }
		function icons-load-definitions() { typeset -gA ICONS; ICONS[git-branch-ahead]="AHEAD"; ICONS[git-branch-behind]="BEHIND" }
		function git-worktree-distance-raw() { echo "1▮0" }
		GIT_DIRECTORY_IS_REPOSITORY=1
		GIT_DIRECTORY_IS_WORKTREE=1
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_worktree_distance
		echo "${OROSHI_PROMPT_PARTS[git_worktree_distance]}"
ZSCRIPT
  bats_run_zsh "source $script"
  [ "$status" -eq 0 ]
  [ "$output" = "%F{123}1AHEAD%f" ]
}

@test "git_worktree_distance shows only behind when ahead=0 behind=1" {
  local script="$BATS_TMP_DIR/gwt-dist-5.zsh"
  cat >"$script" <<'ZSCRIPT'
		source $OROSHI_ROOT/tools/term/zsh/config/prompt/git/git_worktree_distance.zsh
		function colors-load-definitions() { typeset -gA COLORS; COLORS[git-ahead]="123"; COLORS[git-behind]="456" }
		function icons-load-definitions() { typeset -gA ICONS; ICONS[git-branch-ahead]="AHEAD"; ICONS[git-branch-behind]="BEHIND" }
		function git-worktree-distance-raw() { echo "0▮1" }
		GIT_DIRECTORY_IS_REPOSITORY=1
		GIT_DIRECTORY_IS_WORKTREE=1
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_worktree_distance
		echo "${OROSHI_PROMPT_PARTS[git_worktree_distance]}"
ZSCRIPT
  bats_run_zsh "source $script"
  [ "$status" -eq 0 ]
  [ "$output" = "%F{456}1BEHIND%f" ]
}

@test "git_worktree_distance shows both with space between when ahead=1 behind=1" {
  local script="$BATS_TMP_DIR/gwt-dist-6.zsh"
  cat >"$script" <<'ZSCRIPT'
		source $OROSHI_ROOT/tools/term/zsh/config/prompt/git/git_worktree_distance.zsh
		function colors-load-definitions() { typeset -gA COLORS; COLORS[git-ahead]="123"; COLORS[git-behind]="456" }
		function icons-load-definitions() { typeset -gA ICONS; ICONS[git-branch-ahead]="AHEAD"; ICONS[git-branch-behind]="BEHIND" }
		function git-worktree-distance-raw() { echo "1▮1" }
		GIT_DIRECTORY_IS_REPOSITORY=1
		GIT_DIRECTORY_IS_WORKTREE=1
		declare -Ag OROSHI_PROMPT_PARTS
		oroshi-prompt-populate:git_worktree_distance
		echo "${OROSHI_PROMPT_PARTS[git_worktree_distance]}"
ZSCRIPT
  bats_run_zsh "source $script"
  [ "$status" -eq 0 ]
  [ "$output" = "%F{123}1AHEAD%f %F{456}1BEHIND%f" ]
}
