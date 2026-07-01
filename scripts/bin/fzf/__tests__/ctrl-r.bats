bats_load_library 'helper'

setup() {
  bats_tmp_dir
  printf ': 1680000001:0;ls\n: 1680000002:0;echo hello\n: 1680000003:0;git status\n' > "$BATS_TMP_DIR/histfile"
  bats_mock_env "HISTFILE" "$BATS_TMP_DIR/histfile"
  bats_mock_env "OROSHI_TMP_FOLDER" "$BATS_TMP_DIR/oroshi-tmp"
  # Pre-create a fresh output cache so --source always serves from cache (no background spawn)
  mkdir -p "$BATS_TMP_DIR/oroshi-tmp/fzf"
  printf 'git status▮git status\necho hello▮echo hello\nls▮ls\n' > "$BATS_TMP_DIR/oroshi-tmp/fzf/ctrl-r.cache"
  touch -d "+1 day" "$BATS_TMP_DIR/oroshi-tmp/fzf/ctrl-r.cache"
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

@test "fzf-source: serves from output cache when fresher than HISTFILE" {
  printf 'cached-cmd▮cached-cmd\n' > "$BATS_TMP_DIR/oroshi-tmp/fzf/ctrl-r.cache"
  touch -d "+1 second" "$BATS_TMP_DIR/oroshi-tmp/fzf/ctrl-r.cache"
  bats_run_zsh "ctrl-r --source"
  [ "$status" -eq 0 ]
  [ "$output" = "cached-cmd▮cached-cmd" ]
}

# fzf-source (stale cache — raw path)
# Mock ctrl-r to intercept background --colorize spawn

@test "fzf-source: strips ZSH extended history timestamp prefix when cache is stale" {
  rm "$BATS_TMP_DIR/oroshi-tmp/fzf/ctrl-r.cache"
  ctrl-r() {
    [[ "$1" == "--colorize" ]] && return 0
    command ctrl-r "$@"
  }
  bats_mock ctrl-r
  bats_run_zsh "ctrl-r --source"
  [ "$status" -eq 0 ]
  [[ "$output" == *"git status"* ]]
  [[ "$output" != *": 168"* ]]
}

@test "fzf-source: does not output empty lines when cache is stale" {
  printf ': 1680000001:0;ls\n\n: 1680000002:0;echo hello\n' > "$BATS_TMP_DIR/histfile"
  rm "$BATS_TMP_DIR/oroshi-tmp/fzf/ctrl-r.cache"
  ctrl-r() {
    [[ "$1" == "--colorize" ]] && return 0
    command ctrl-r "$@"
  }
  bats_mock ctrl-r
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
