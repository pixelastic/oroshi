load 'helper'

setup() {
  export TMP_DIRECTORY="$(bats_tmp)"
  git init "$TMP_DIRECTORY/my-repo"
  cd "$TMP_DIRECTORY/my-repo"
  git config user.email "test@test.com"
  git config user.name "Test"
  git commit --allow-empty -m "init"
  git worktree add "$TMP_DIRECTORY/my-repo--fix_bug" -b fix/bug
  mkdir -p "$TMP_DIRECTORY/my-repo--fix_bug/src"
}

teardown() {
  rm -rf "$TMP_DIRECTORY"
}

@test "shows project prefix when in worktree of registered project" {
  cd "$TMP_DIRECTORY/my-repo--fix_bug"
  run zsh -c "
    source ~/.oroshi/config/term/zsh/zshenv.zsh
    source ~/.oroshi/config/term/zsh/prompt/path.zsh
    PROJECTS_INDEX_BY_PATH=MYKEY
    PROJECT_MYKEY_PATH=$TMP_DIRECTORY/my-repo/
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

@test "shows plain path when in worktree of unregistered project" {
  cd "$TMP_DIRECTORY/my-repo--fix_bug"
  run zsh -c "
    source ~/.oroshi/config/term/zsh/zshenv.zsh
    source ~/.oroshi/config/term/zsh/prompt/path.zsh
    PROJECTS_INDEX_BY_PATH=
    GIT_DIRECTORY_IS_WORKTREE=1
    declare -Ag OROSHI_PROMPT_PARTS
    oroshi-prompt-populate:path
    echo \"\${OROSHI_PROMPT_PARTS[path]}\"
  "
  [ "$status" -eq 0 ]
  [[ "$output" == *"my-repo--fix_bug"* ]]
}

@test "path after prefix is relative to worktree root" {
  cd "$TMP_DIRECTORY/my-repo--fix_bug/src"
  run zsh -c "
    source ~/.oroshi/config/term/zsh/zshenv.zsh
    source ~/.oroshi/config/term/zsh/prompt/path.zsh
    PROJECTS_INDEX_BY_PATH=MYKEY
    PROJECT_MYKEY_PATH=$TMP_DIRECTORY/my-repo/
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
  [[ "$output" == *"src"* ]]
  [[ "$output" != *"my-repo--fix_bug"* ]]
}

@test "shows project prefix outside worktree for registered project" {
  cd "$TMP_DIRECTORY/my-repo"
  run zsh -c "
    source ~/.oroshi/config/term/zsh/zshenv.zsh
    source ~/.oroshi/config/term/zsh/prompt/path.zsh
    PROJECTS_INDEX_BY_PATH=MYKEY
    PROJECT_MYKEY_PATH=$TMP_DIRECTORY/my-repo/
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
}
