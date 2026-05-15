load 'helper'

setup() {
  export TEST_TMP="$(mktemp -d)"
  export OROSHI_WORKTREES_DIR="$TEST_TMP/worktrees"
  mkdir -p "$OROSHI_WORKTREES_DIR"
  git init "$TEST_TMP/my-repo"
  cd "$TEST_TMP/my-repo"
  git commit --allow-empty -m "init"
  git worktree add "$OROSHI_WORKTREES_DIR/my-repo--fix_bug" -b fix/bug
}

teardown() {
  rm -rf "$TEST_TMP"
}

@test "prompt part is non-empty inside a worktree" {
  cd "$OROSHI_WORKTREES_DIR/my-repo--fix_bug"
  run zsh -c '
    source ~/.oroshi/config/term/zsh/zshenv.zsh
    source ~/.oroshi/config/term/zsh/prompt/git.zsh
    GIT_DIRECTORY_IS_REPOSITORY=1
    GIT_DIRECTORY_IS_WORKTREE=1
    declare -Ag OROSHI_PROMPT_PARTS
    oroshi-prompt-populate:git_is_worktree
    echo "${OROSHI_PROMPT_PARTS[git_is_worktree]}"
  '
  [ "$output" != "" ]
}

@test "prompt part is empty in the Git Repo Main" {
  cd "$TEST_TMP/my-repo"
  run zsh -c '
    source ~/.oroshi/config/term/zsh/zshenv.zsh
    source ~/.oroshi/config/term/zsh/prompt/git.zsh
    GIT_DIRECTORY_IS_REPOSITORY=1
    declare -Ag OROSHI_PROMPT_PARTS
    oroshi-prompt-populate:git_is_worktree
    echo "${OROSHI_PROMPT_PARTS[git_is_worktree]}"
  '
  [ "$output" = "" ]
}
