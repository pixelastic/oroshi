bats_load_library 'helper'

setup() {
  bats_git_dir 'my-repo'
  bats_git_worktree 'fix/bug'
  mkdir -p "${BATS_GIT_WORKTREES}fix-bug/src"
}

teardown() {
  bats_cleanup
}

@test "shows project prefix when in worktree of registered project" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  run zsh -c "
    source ~/.oroshi/tools/term/zsh/config/zshenv.zsh
    source ~/.oroshi/tools/term/zsh/config/prompt/path.zsh
    PROJECTS_INDEX_BY_PATH=MYKEY
    PROJECT_MYKEY_PATH=$BATS_GIT_DIR/
    PROJECT_MYKEY_NAME=my-project
    PROJECT_MYKEY_BACKGROUND=200
    PROJECT_MYKEY_FOREGROUND=201
    PROJECT_MYKEY_ICON=''
    GIT_DIRECTORY_IS_WORKTREE=1
    declare -Ag OROSHI_PROMPT_PARTS
    oroshi-prompt-populate:path
    echo \"\${OROSHI_PROMPT_PARTS[path]}\"
  "
  [ "$status" -eq 0 ]
  [[ "$output" == *"my-project"* ]]
}

@test "shows project prefix outside worktree for registered project" {
  cd "$BATS_GIT_DIR"
  run zsh -c "
    source ~/.oroshi/tools/term/zsh/config/zshenv.zsh
    source ~/.oroshi/tools/term/zsh/config/prompt/path.zsh
    PROJECTS_INDEX_BY_PATH=MYKEY
    PROJECT_MYKEY_PATH=$BATS_GIT_DIR/
    PROJECT_MYKEY_NAME=my-project
    PROJECT_MYKEY_BACKGROUND=200
    PROJECT_MYKEY_FOREGROUND=201
    PROJECT_MYKEY_ICON=''
    GIT_DIRECTORY_IS_WORKTREE=0
    declare -Ag OROSHI_PROMPT_PARTS
    oroshi-prompt-populate:path
    echo \"\${OROSHI_PROMPT_PARTS[path]}\"
  "
  [ "$status" -eq 0 ]
  [[ "$output" == *"my-project"* ]]
  [[ "$output" != *"main"* ]]
}

@test "path part contains branch name when inside a linked worktree" {
  cd "${BATS_GIT_WORKTREES}fix-bug"
  run zsh -c "
    source ~/.oroshi/config/term/zsh/zshenv.zsh
    source $OROSHI_ROOT/config/term/zsh/prompt/path.zsh
    PROJECTS_INDEX_BY_PATH=MYKEY
    PROJECT_MYKEY_PATH=$BATS_GIT_DIR/
    PROJECT_MYKEY_NAME=my-project
    PROJECT_MYKEY_BACKGROUND=200
    PROJECT_MYKEY_FOREGROUND=201
    PROJECT_MYKEY_ICON=''
    GIT_DIRECTORY_IS_WORKTREE=1
    declare -Ag OROSHI_PROMPT_PARTS
    oroshi-prompt-populate:path
    echo \"\${OROSHI_PROMPT_PARTS[path]}\"
  "
  [ "$status" -eq 0 ]
  [[ "$output" == *"my-project"* ]]
  [[ "$output" == *"fix/bug"* ]]
}

@test "path_worktree_dir shows sub-path relative to worktree root" {
  cd "${BATS_GIT_WORKTREES}fix-bug/src"
  run zsh -c "
    source ~/.oroshi/config/term/zsh/zshenv.zsh
    source $OROSHI_ROOT/config/term/zsh/prompt/path.zsh
    PROJECTS_INDEX_BY_PATH=MYKEY
    PROJECT_MYKEY_PATH=$BATS_GIT_DIR/
    PROJECT_MYKEY_NAME=my-project
    PROJECT_MYKEY_BACKGROUND=200
    PROJECT_MYKEY_FOREGROUND=201
    PROJECT_MYKEY_ICON=''
    GIT_DIRECTORY_IS_WORKTREE=1
    declare -Ag OROSHI_PROMPT_PARTS
    oroshi-prompt-populate:path_worktree_dir
    echo \"\${OROSHI_PROMPT_PARTS[path_worktree_dir]}\"
  "
  [ "$status" -eq 0 ]
  [[ "$output" == *"src"* ]]
  [[ "$output" != *"my-repo"* ]]
  [[ "$output" != *"worktrees"* ]]
}
