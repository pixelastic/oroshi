# BATS Testing

- Tests in `__tests__/` sibling folder, named `<function-name>.bats`
- If the `setup` is complex, add comments to explain what it does
- Use `bats <filepaths>` to run the tests

## Helper

- Always load the helper: `bats_load_library 'helper'`
- Use `bats_tmp_dir` to create an isolated test sandbox dir
- Use `bats_git_dir` to create an isolated test git repo dir
- Use `bats_cleanup` to remove any isolated test dir
- Use `bats_run_zsh "command-to-test"`
    - If you need to `cd` inside a specific directory, make it as part of the command passed to `bats_run_zsh`
- Use `bats_mock` to mock commands
- Full helper code available at `tools/term/bats/config/helper`

## Example

```bash
bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

teardown() {
  bats_cleanup
}

@test "exits 0 on valid input" {
  bats_run_zsh "my-script some-arg"
  [[ "$status" -eq 0 ]]
}

@test "prints error on stdin" {
  bats_run_zsh "my-script" <<<"input"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Usage"* ]]
}
```

### `bats_tmp_dir`

Creates an isolated directory, specific to that test.

- Path is then accessible as `$BATS_TMP_DIR`
- Run `bats_cleanup` in `teardown` to remove it.

## `bats_git_dir`

Creates an isolated git repo, specific to that test.

- It has one commit, on branch `main`
- Path is then accessible as `$BATS_GIT_DIR`
- Use `bats_git` to run git commands in that repo

```bash
setup() {
  bats_git_dir 'my-repo'
}

@test "returns current branch" {
  bats_git checkout -b fix/bug
  bats_run_zsh "cd $BATS_GIT_DIR && my-script some-arg"
  [ "$output" = "fix/bug" ]
}
```

## `bats_git_worktree`

Creates a linked worktree inside the isolated git repo. Scripts read `$OROSHI_WORKTREES_DIR` at runtime — export `MOCK_OROSHI_WORKTREES_DIR` in `setup()` to control where worktrees land.

```bash
setup() {
  bats_git_dir 'my-repo'
  export MOCK_OROSHI_WORKTREES_DIR="$BATS_TMP_DIR/worktrees"
  mkdir -p "$MOCK_OROSHI_WORKTREES_DIR"
}

@test "creates a worktree directory" {
  bats_run_zsh "cd $BATS_GIT_DIR && my-function fix/bug"
  [ "$status" -eq 0 ]
  [ -d "$MOCK_OROSHI_WORKTREES_DIR/my-repo--fix_bug" ]
}
```

### `bats_mock`

Overwrites existing commands with custom one, only for that test.

- Start by defining a function with the same name
- Then call `bats_mock` with that function name
- Tip: To capture calls, write to a file in `$BATS_TMP_DIR` in the mock

```bash
@test "passes slugified name to clipboard" {
  pbcopy() { echo "$1" > "$BATS_TMP_DIR/clipboard.txt"; }
  bats_mock pbcopy

  bats_run_zsh "my-script Hello World"
  [ "$(cat "$BATS_TMP_DIR/clipboard.txt")" = "helloWorld" ]
}
```

## `bats_strip_ansi`

Strip ANSI color codes from strings:

- Use to assert text from colored output.

```bash
@test "shows behind count" {
  bats_run_zsh "my-script Hello World"
  local stripped="$(bats_strip_ansi "$output")"
  [[ "$stripped" == *"3"* ]]
}
```
