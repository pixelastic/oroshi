bats_load_library 'helper'

setup() {
  bats_tmp_dir
  hooksDir="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  sourcePrefix="source '${hooksDir}/lib/hacks.zsh'"
}

# Run hacksRemovePythonNoOp on the command in $1
# The command goes through a file so that its quotes and newlines reach zsh untouched
runRemove() {
  printf '%s' "$1" > "$BATS_TMP_DIR/command.txt"
  bats_run_zsh "${sourcePrefix}; hacksRemovePythonNoOp \"\$(<'${BATS_TMP_DIR}/command.txt')\""
}

# hacksRemovePythonNoOp: removal

@test "removes an empty python3 heredoc followed by || echo nopython" {
  runRemove $'python3 - <<\'EOF\' 2>/dev/null || echo nopython\nEOF\ngrep -n \'Force every tab\' kitty-session-save'
  [[ "$status" -eq 0 ]]
  [[ "$output" = "grep -n 'Force every tab' kitty-session-save" ]]
}

@test "removes an empty python3 heredoc followed by || true" {
  runRemove $'python3 - <<\'EOF\' 2>/dev/null || true\nEOF\ngit status'
  [[ "$status" -eq 0 ]]
  [[ "$output" = "git status" ]]
}

@test "removes an empty python3 heredoc after a cd prefix, with its &&" {
  runRemove $'cd /home/tim/docs/api && python3 - <<\'EOF\' 2>/dev/null || echo nopython\nEOF\necho; sed -n 44,48p search.md'
  [[ "$status" -eq 0 ]]
  [[ "$output" = $'cd /home/tim/docs/api\necho; sed -n 44,48p search.md' ]]
}

@test "removes a python3 -c 1 line between two sed -i commands" {
  runRemove $'sed -i \'s/a/b/\' file\npython3 -c 1 2>/dev/null\nsed -i \'s/c/d/\' file'
  [[ "$status" -eq 0 ]]
  [[ "$output" = $'sed -i \'s/a/b/\' file\nsed -i \'s/c/d/\' file' ]]
}

@test "removes python3 -c pass" {
  runRemove 'python3 -c pass'
  [[ "$status" -eq 0 ]]
  [[ -z "$output" ]]
}

@test "removes the && that follows a no-op python3 call" {
  runRemove 'python3 -c pass && echo hello'
  [[ "$status" -eq 0 ]]
  [[ "$output" = "echo hello" ]]
}

@test "removes the ; that precedes a no-op python3 call" {
  runRemove 'cd /tmp; python3 -c 1 || true'
  [[ "$status" -eq 0 ]]
  [[ "$output" = "cd /tmp" ]]
}

@test "removes an empty python3 heredoc followed by || echo nopy, after a cd prefix with ;" {
  runRemove $'cd /home/tim/worktree; python3 - <<\'E\' 2>/dev/null || echo nopy\nE\nsed -n 1p file'
  [[ "$status" -eq 0 ]]
  [[ "$output" = $'cd /home/tim/worktree\nsed -n 1p file' ]]
}

@test "removes an empty python3 heredoc followed by || echo with a quoted message" {
  runRemove $'python3 - <<\'EOF\' 2>/dev/null || echo "no python"\nEOF\nls'
  [[ "$status" -eq 0 ]]
  [[ "$output" = "ls" ]]
}

@test "removes an empty python3 heredoc followed by || echo nopy, without the redirect" {
  runRemove $'python3 - <<\'EOF\' || echo nopy\nEOF\nls'
  [[ "$status" -eq 0 ]]
  [[ "$output" = "ls" ]]
}

@test "removes python3 -c 1 followed by || echo nopy" {
  runRemove 'python3 -c 1 || echo nopy && ls'
  [[ "$status" -eq 0 ]]
  [[ "$output" = "ls" ]]
}

# hacksRemovePythonNoOp: preservation

@test "keeps the command that follows a python3 call with an || echo fallback" {
  runRemove $'python3 -c 1 || echo nopy; rm file'
  [[ "$status" -eq 0 ]]
  [[ "$output" = "rm file" ]]
}

@test "keeps a python3 call whose fallback is not echo or true" {
  runRemove $'python3 - <<\'EOF\' || rm file\nEOF\nls'
  [[ "$status" -eq 0 ]]
  [[ "$output" = $'python3 - <<\'EOF\' || rm file\nEOF\nls' ]]
}

@test "keeps a python3 call whose echo fallback has several unquoted words" {
  runRemove 'python3 -c 1 || echo no python here'
  [[ "$status" -eq 0 ]]
  [[ "$output" = "python3 -c 1 || echo no python here" ]]
}

@test "keeps a python3 heredoc that has a body" {
  runRemove $'python3 - <<\'EOF\' 2>/dev/null || echo nopython\nprint(1)\nEOF\necho done'
  [[ "$status" -eq 0 ]]
  [[ "$output" = $'python3 - <<\'EOF\' 2>/dev/null || echo nopython\nprint(1)\nEOF\necho done' ]]
}

@test "keeps python3 script.py" {
  runRemove 'python3 script.py'
  [[ "$status" -eq 0 ]]
  [[ "$output" = "python3 script.py" ]]
}

@test "keeps python3 -c with a real program" {
  runRemove "python3 -c 'print(1)'"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "python3 -c 'print(1)'" ]]
}

@test "keeps python3 -c programs that only start with 1 or pass" {
  local program
  for program in '1000' 'passthrough()' '1+1' '1 foo'; do
    runRemove "python3 -c ${program}"
    [[ "$status" -eq 0 ]]
    [[ "$output" = "python3 -c ${program}" ]]
  done
}

@test "keeps a command with no python unchanged" {
  runRemove $'cd /tmp && echo hello\nls -la | grep foo'
  [[ "$status" -eq 0 ]]
  [[ "$output" = $'cd /tmp && echo hello\nls -la | grep foo' ]]
}
