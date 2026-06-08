bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

teardown() {
  bats_cleanup
}

@test "git-branch-color main returns GIT_BRANCH_MAIN color" {
  cat >"$BATS_TMP_DIR/test-main.zsh" <<'ZSCRIPT'
    source ~/.oroshi/tools/term/zsh/config/zshenv.zsh
    source "$ZSH_CONFIG_PATH/theming/dist/colors.zsh"
    unset ${(k)parameters[(I)COLOR_*]}
    result="$(git-branch-color main)"
    [[ "$result" == "$colors[GIT_BRANCH_MAIN]" ]] && echo "ok"
ZSCRIPT
  bats_run_zsh "$BATS_TMP_DIR/test-main.zsh"
  [ "$status" -eq 0 ]
  [ "$output" = "ok" ]
}

@test "git-branch-color unknown branch returns GIT_BRANCH color" {
  cat >"$BATS_TMP_DIR/test-unknown.zsh" <<'ZSCRIPT'
    source ~/.oroshi/tools/term/zsh/config/zshenv.zsh
    source "$ZSH_CONFIG_PATH/theming/dist/colors.zsh"
    unset ${(k)parameters[(I)COLOR_*]}
    result="$(git-branch-color some-feature)"
    [[ "$result" == "$colors[GIT_BRANCH]" ]] && echo "ok"
ZSCRIPT
  bats_run_zsh "$BATS_TMP_DIR/test-unknown.zsh"
  [ "$status" -eq 0 ]
  [ "$output" = "ok" ]
}
