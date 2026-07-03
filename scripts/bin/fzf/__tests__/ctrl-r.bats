bats_load_library 'helper'

setup() {
  bats_tmp_dir
  printf ': 1680000001:0;ls\n: 1680000002:0;echo hello\n: 1680000003:0;git status\n' > "$BATS_TMP_DIR/histfile"
  bats_mock_env "HISTFILE" "$BATS_TMP_DIR/histfile"
  bats_mock_env "OROSHI_TMP_FOLDER" "$BATS_TMP_DIR/oroshi-tmp"
  bats_mock_env "CLAUDECODE" ""
  # Pre-create a fresh output cache + matching meta so --source serves from cache (fresh)
  mkdir -p "$BATS_TMP_DIR/oroshi-tmp/fzf/ctrl-r"
  printf 'git status▮git status\necho hello▮echo hello\nls▮ls\n' > "$BATS_TMP_DIR/oroshi-tmp/fzf/ctrl-r/cache"
  wc -l < "$BATS_TMP_DIR/histfile" > "$BATS_TMP_DIR/oroshi-tmp/fzf/ctrl-r/last-history-line-count"
}

# fzf-source (served from output cache)

@test "fzf-source: outputs one entry per line" {
  bats_run_zsh "ctrl-r --source"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 3 ]
}

@test "fzf-source: outputs raw▮colored format" {
  bats_run_zsh "ctrl-r --source"
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == *"▮"* ]]
}

@test "fzf-source: field 1 contains no ANSI codes" {
  bats_run_zsh "ctrl-r --source"
  [ "$status" -eq 0 ]
  local field1="${lines[0]%%▮*}"
  [[ "$field1" != *$'\e['* ]]
}

@test "fzf-source: serves from output cache when line count matches meta" {
  printf 'cached-cmd▮cached-cmd\n' > "$BATS_TMP_DIR/oroshi-tmp/fzf/ctrl-r/cache"
  bats_run_zsh "ctrl-r --source"
  [ "$status" -eq 0 ]
  [ "$output" = "cached-cmd▮cached-cmd" ]
}

# fzf-source (stale cache — raw path)

@test "fzf-source: strips ZSH extended history timestamp prefix when cache is stale" {
  rm "$BATS_TMP_DIR/oroshi-tmp/fzf/ctrl-r/cache"
  bats_run_zsh "ctrl-r --source"
  [ "$status" -eq 0 ]
  [[ "$output" == *"git status"* ]]
  [[ "$output" != *": 168"* ]]
}

@test "fzf-source: does not output empty lines when cache is stale" {
  printf ': 1680000001:0;ls\n\n: 1680000002:0;echo hello\n' > "$BATS_TMP_DIR/histfile"
  rm "$BATS_TMP_DIR/oroshi-tmp/fzf/ctrl-r/cache"
  bats_run_zsh "ctrl-r --source"
  [ "$status" -eq 0 ]
  local line
  for line in "${lines[@]}"; do
    [ -n "$line" ]
  done
}

# fzf-postprocess

@test "fzf-postprocess: returns raw field from raw▮colored input" {
  bats_run_zsh "printf 'git status\xe2\x96\xae\e[38;5;45mgit\e[0m status\n' | ctrl-r --postprocess"
  [ "$status" -eq 0 ]
  [ "$output" = "git status" ]
}

@test "fzf-postprocess: outputs nothing on empty stdin" {
  bats_run_zsh "printf '' | ctrl-r --postprocess"
  [ "$output" = "" ]
}

# fzf-options

@test "fzf-options: includes --delimiter=▮" {
  bats_run_zsh "ctrl-r --options"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--delimiter=▮"* ]]
}

@test "fzf-options: includes --with-nth=2" {
  bats_run_zsh "ctrl-r --options"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--with-nth=2"* ]]
}

# fzf-history-entries

@test "fzf-history-entries: outputs commands in reverse chronological order" {
  bats_run_zsh "source \$(which ctrl-r) --no-dispatch && fzf-history-entries"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "git status" ]
  [ "${lines[1]}" = "echo hello" ]
  [ "${lines[2]}" = "ls" ]
}

@test "fzf-history-entries: strips ZSH extended history timestamp prefix" {
  bats_run_zsh "source \$(which ctrl-r) --no-dispatch && fzf-history-entries"
  [ "$status" -eq 0 ]
  [[ "$output" != *": 168"* ]]
  [[ "$output" != *":0;"* ]]
}

@test "fzf-history-entries: skips empty lines" {
  printf ': 1680000001:0;ls\n\n: 1680000002:0;echo hello\n' > "$BATS_TMP_DIR/histfile"
  bats_run_zsh "source \$(which ctrl-r) --no-dispatch && fzf-history-entries"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 2 ]
}

@test "fzf-history-entries: with count argument outputs only that many entries" {
  bats_run_zsh "source \$(which ctrl-r) --no-dispatch && fzf-history-entries 2"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 2 ]
  [ "${lines[0]}" = "git status" ]
  [ "${lines[1]}" = "echo hello" ]
}

@test "fzf-history-entries: with no argument outputs all entries" {
  bats_run_zsh "source \$(which ctrl-r) --no-dispatch && fzf-history-entries"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 3 ]
}

@test "fzf-history-entries: duplicate commands keep only the most recent" {
  printf ': 1680000001:0;ls\n: 1680000002:0;echo hello\n: 1680000003:0;ls\n' > "$BATS_TMP_DIR/histfile"
  bats_run_zsh "source \$(which ctrl-r) --no-dispatch && fzf-history-entries"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 2 ]
  [ "${lines[0]}" = "ls" ]
  [ "${lines[1]}" = "echo hello" ]
}

# fzf-history-highlight-line

@test "fzf-history-highlight-line: produces ANSI-colored output for a known command" {
  bats_run_zsh "source \$(which ctrl-r) --no-dispatch && fzf-history-highlight-line 'echo hello' && printf '%s' \"\$REPLY\""
  [ "$status" -eq 0 ]
  [[ "$output" == *$'\e['* ]]
}

@test "fzf-history-highlight-line: output contains no unclosed ANSI sequences" {
  bats_run_zsh "source \$(which ctrl-r) --no-dispatch && fzf-history-highlight-line 'echo hello' && printf '%s' \"\$REPLY\""
  [ "$status" -eq 0 ]
  [[ "$output" == *$'\e[0m' ]]
}

@test "fzf-history-highlight-line: sets REPLY without printing to stdout" {
  local stdoutFile="$BATS_TMP_DIR/highlight-stdout"
  bats_run_zsh "source \$(which ctrl-r) --no-dispatch && fzf-history-highlight-line 'echo hello' > $stdoutFile && [[ ! -s $stdoutFile ]] && [[ -n \"\$REPLY\" ]]"
  [ "$status" -eq 0 ]
}

# fzf-history-update-cache mutex

@test "fzf-history-update-cache: prints message and exits cleanly when mutex is already taken" {
  # Remove meta so HISTORY_DIFF_COUNT > 0 (cache stale → mutex logic runs)
  rm "$BATS_TMP_DIR/oroshi-tmp/fzf/ctrl-r/last-history-line-count"
  local lockDir="$BATS_TMP_DIR/oroshi-tmp/fzf/ctrl-r/colorize.lock"
  mkdir -p "$lockDir"
  printf '%s\n' "$$" >"$lockDir/pid"
  bats_run_zsh "source \$(which ctrl-r) --no-dispatch && fzf-history-update-cache"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Cache updating already in progress"* ]]
}
