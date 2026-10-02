bats_load_library 'helper'

setup() {
  bats_tmp_dir
  printf ': 1680000001:0;ls\n: 1680000002:0;echo hello\n' > "$BATS_TMP_DIR/histfile"
  bats_mock_env "HISTFILE" "$BATS_TMP_DIR/histfile"
  bats_mock_env "OROSHI_FOLDER_STATE" "$BATS_TMP_DIR/oroshi-tmp"
  # Pre-create a fresh cache + matching line count so ctrl-r serves from cache
  mkdir -p "$BATS_TMP_DIR/oroshi-tmp/fzf/ctrl-r"
  printf 'ls▮ls\necho hello▮echo hello\n' > "$BATS_TMP_DIR/oroshi-tmp/fzf/ctrl-r/cache"
  wc -l < "$BATS_TMP_DIR/histfile" > "$BATS_TMP_DIR/oroshi-tmp/fzf/ctrl-r/last-history-line-count"
}

# --no-dispatch

@test "--no-dispatch: exits 0" {
  bats_run_zsh "ctrl-r --no-dispatch"
  [[ "$status" -eq 0 ]]
}

@test "--no-dispatch does not invoke fzf" {
  fzf() {
    touch "$OROSHI_FOLDER_STATE/fzf-was-invoked"
    cat
  }
  bats_mock fzf
  bats_run_zsh "ctrl-r --no-dispatch"
  [[ "$status" -eq 0 ]]
  [[ ! -f "$BATS_TMP_DIR/oroshi-tmp/fzf-was-invoked" ]]
}

# Existing dispatch unchanged

@test "dispatch: --source still dispatches to fzf-source" {
  bats_run_zsh "ctrl-r --source"
  [[ "$status" -eq 0 ]]
  [[ "${#lines[@]}" -gt 0 ]]
}

@test "dispatch: no flags dispatches to fzf-main" {
  fzf() {
    touch "$OROSHI_FOLDER_STATE/fzf-was-invoked"
    cat
  }
  bats_mock fzf
  bats_run_zsh "ctrl-r"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TMP_DIR/oroshi-tmp/fzf-was-invoked" ]]
}

# fzf-postprocess (init.zsh default)

@test "init.zsh default fzf-postprocess: strips ▮ field, returns raw" {
  bats_run_zsh "source ${BATS_TEST_DIRNAME}/../__lib/init.zsh && printf 'foo\xe2\x96\xaebar\n' | fzf-postprocess"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "foo" ]]
}

@test "init.zsh default fzf-postprocess: outputs nothing on empty stdin" {
  bats_run_zsh "source ${BATS_TEST_DIRNAME}/../__lib/init.zsh && printf '' | fzf-postprocess"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "" ]]
}

@test "init.zsh default fzf-postprocess: handles multi-line selection" {
  bats_run_zsh "source ${BATS_TEST_DIRNAME}/../__lib/init.zsh && printf 'a\xe2\x96\xaedisplay-a\nb\xe2\x96\xaedisplay-b\n' | fzf-postprocess"
  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" = "a" ]]
  [[ "${lines[1]}" = "b" ]]
}
