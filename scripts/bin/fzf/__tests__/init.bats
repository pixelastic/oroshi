bats_load_library 'helper'

setup() {
  bats_tmp_dir
  printf ': 1680000001:0;ls\n: 1680000002:0;echo hello\n' > "$BATS_TMP_DIR/histfile"
  bats_mock_env "HISTFILE" "$BATS_TMP_DIR/histfile"
  bats_mock_env "OROSHI_TMP_FOLDER" "$BATS_TMP_DIR/oroshi-tmp"
  mkdir -p "$BATS_TMP_DIR/oroshi-tmp/fzf"
  printf 'ls▮ls\necho hello▮echo hello\n' > "$BATS_TMP_DIR/oroshi-tmp/fzf/ctrl-r.cache"
  wc -l < "$BATS_TMP_DIR/histfile" > "$BATS_TMP_DIR/oroshi-tmp/fzf/ctrl-r.meta"
}

# --no-dispatch

@test "--no-dispatch: produces no output and exits 0" {
  bats_run_zsh "ctrl-r --no-dispatch"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "--no-dispatch: source defines functions without dispatching" {
  fzf() {
    touch "$OROSHI_TMP_FOLDER/fzf-was-invoked"
    cat
  }
  bats_mock fzf
  bats_run_zsh "source \$(which ctrl-r) --no-dispatch && fzf-source | head -1"
  [ "$status" -eq 0 ]
  [[ "$output" == *"▮"* ]]
  [ ! -f "$BATS_TMP_DIR/oroshi-tmp/fzf-was-invoked" ]
}

# Existing dispatch unchanged

@test "dispatch: --source still dispatches to fzf-source" {
  bats_run_zsh "ctrl-r --source"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -gt 0 ]
}

@test "dispatch: no flags dispatches to fzf-main" {
  fzf() { cat; }
  bats_mock fzf
  bats_run_zsh "ctrl-r"
  [ "$status" -eq 0 ]
  [[ "$output" == *"ls"* ]]
}

# fzf-postprocess (init.zsh default)

@test "init.zsh default fzf-postprocess: strips ▮ field, returns raw" {
  bats_run_zsh "source \$(dirname \$(which ctrl-o))/__lib/init.zsh && printf 'foo\xe2\x96\xaebar\n' | fzf-postprocess"
  [ "$status" -eq 0 ]
  [ "$output" = "foo" ]
}

@test "init.zsh default fzf-postprocess: outputs nothing on empty stdin" {
  bats_run_zsh "source \$(dirname \$(which ctrl-o))/__lib/init.zsh && printf '' | fzf-postprocess"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "init.zsh default fzf-postprocess: handles multi-line selection" {
  bats_run_zsh "source \$(dirname \$(which ctrl-o))/__lib/init.zsh && printf 'a\xe2\x96\xaedisplay-a\nb\xe2\x96\xaedisplay-b\n' | fzf-postprocess"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "a" ]
  [ "${lines[1]}" = "b" ]
}
