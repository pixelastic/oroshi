# issue-0010 — prompt: git_is_worktree

New synchronous left-prompt part that displays the Worktree icon `󰙅` when the shell is inside a Worktree.

## Failing test

```bats
# scripts/bin/__tests__/oroshi-prompt-git-is-worktree.bats

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
```

## What to implement

1. **`config/term/zsh/prompt/git.zsh`** — add `oroshi-prompt-populate:git_is_worktree`:
   - Returns early if `$GIT_DIRECTORY_IS_REPOSITORY == 0`
   - Calls `git-directory-is-worktree`; returns early (empty) if not in a Worktree
   - Sets `OROSHI_PROMPT_PARTS[git_is_worktree]` to `%F{$COLOR_ALIAS_GIT_WORKTREE}󰙅%f`

2. **`config/term/zsh/prompt/index.zsh`**:
   - Add `git_is_worktree` to `OROSHI_SYNCHRONOUS_PROMPT_PARTS`
   - Add `$OROSHI_PROMPT_PARTS[git_is_worktree]` to `oroshi-prompt-left`, alongside `git_is_submodule`
