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
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 3 ]]
}

@test "fzf-source: outputs raw▮colored format" {
  bats_run_zsh "ctrl-r --source"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == *"▮"* ]]
}

@test "fzf-source: field 1 contains no ANSI codes" {
  bats_run_zsh "ctrl-r --source"
  [[ "$status" -eq 0 ]]
  local field1="${lines[0]%%▮*}"
  [[ "$field1" != *$'\e['* ]]
}

@test "fzf-source: serves from output cache when line count matches meta" {
  printf 'cached-cmd▮cached-cmd\n' > "$BATS_TMP_DIR/oroshi-tmp/fzf/ctrl-r/cache"
  bats_run_zsh "ctrl-r --source"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "cached-cmd▮cached-cmd" ]]
}

# fzf-source (stale cache — raw path)

@test "fzf-source: strips ZSH extended history timestamp prefix when cache is stale" {
  rm "$BATS_TMP_DIR/oroshi-tmp/fzf/ctrl-r/cache"
  bats_run_zsh "ctrl-r --source"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"git status"* ]]
  [[ "$output" != *": 168"* ]]
}

@test "fzf-source: does not output empty lines when cache is stale" {
  printf ': 1680000001:0;ls\n\n: 1680000002:0;echo hello\n' > "$BATS_TMP_DIR/histfile"
  rm "$BATS_TMP_DIR/oroshi-tmp/fzf/ctrl-r/cache"
  bats_run_zsh "ctrl-r --source"
  [[ "$status" -eq 0 ]]
  local line
  for line in "${lines[@]}"; do
    [[ -n "$line" ]]
  done
}

@test "fzf-source: stale cache outputs in reverse chronological order" {
  rm "$BATS_TMP_DIR/oroshi-tmp/fzf/ctrl-r/cache"
  bats_run_zsh "ctrl-r --source"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]%%▮*}" = "git status" ]]
  [[ "${lines[1]%%▮*}" = "echo hello" ]]
  [[ "${lines[2]%%▮*}" = "ls" ]]
}

@test "fzf-source: stale cache deduplicates commands" {
  printf ': 1680000001:0;ls\n: 1680000002:0;echo hello\n: 1680000003:0;ls\n' > "$BATS_TMP_DIR/histfile"
  rm "$BATS_TMP_DIR/oroshi-tmp/fzf/ctrl-r/cache"
  bats_run_zsh "ctrl-r --source"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]
  [[ "${lines[0]%%▮*}" = "ls" ]]
  [[ "${lines[1]%%▮*}" = "echo hello" ]]
}

# fzf-postprocess

@test "fzf-postprocess: returns raw field from raw▮colored input" {
  bats_run_zsh "printf 'git status\xe2\x96\xae\e[38;5;45mgit\e[0m status\n' | ctrl-r --postprocess"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "git status" ]]
}

@test "fzf-postprocess: outputs nothing on empty stdin" {
  bats_run_zsh "printf '' | ctrl-r --postprocess"
  [[ "$output" = "" ]]
}

# fzf-options

@test "fzf-options: includes --with-nth=2" {
  bats_run_zsh "ctrl-r --options"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"--with-nth=2"* ]]
}

@test "fzf-options: includes --prompt with History label" {
  bats_run_zsh "ctrl-r --options"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"--prompt="* ]]
  [[ "$output" == *"History"* ]]
}

# --regenerate-cache

@test "regenerate-cache: produces ANSI-colored entries in cache file" {
  rm -f "$BATS_TMP_DIR/oroshi-tmp/fzf/ctrl-r/cache" "$BATS_TMP_DIR/oroshi-tmp/fzf/ctrl-r/last-history-line-count"
  bats_run_zsh "ctrl-r --regenerate-cache"
  [[ "$status" -eq 0 ]]
  # Cache file should exist with ANSI codes in field 2
  [[ -f "$BATS_TMP_DIR/oroshi-tmp/fzf/ctrl-r/cache" ]]
  local firstLine="$(head -1 "$BATS_TMP_DIR/oroshi-tmp/fzf/ctrl-r/cache")"
  local field2="${firstLine#*▮}"
  [[ "$field2" == *$'\e['* ]]
}

@test "regenerate-cache: field 1 is uncolored raw command" {
  rm -f "$BATS_TMP_DIR/oroshi-tmp/fzf/ctrl-r/cache" "$BATS_TMP_DIR/oroshi-tmp/fzf/ctrl-r/last-history-line-count"
  bats_run_zsh "ctrl-r --regenerate-cache"
  [[ "$status" -eq 0 ]]
  local firstLine="$(head -1 "$BATS_TMP_DIR/oroshi-tmp/fzf/ctrl-r/cache")"
  local field1="${firstLine%%▮*}"
  [[ "$field1" != *$'\e['* ]]
}

@test "regenerate-cache: exits cleanly when mutex is already taken" {
  rm -f "$BATS_TMP_DIR/oroshi-tmp/fzf/ctrl-r/last-history-line-count"
  local lockDir="$BATS_TMP_DIR/oroshi-tmp/fzf/ctrl-r/colorize.lock"
  mkdir -p "$lockDir"
  printf '%s\n' "$$" >"$lockDir/pid"
  bats_run_zsh "ctrl-r --regenerate-cache"
  [[ "$status" -eq 0 ]]
}
