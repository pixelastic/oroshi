bats_load_library 'helper'

setup() {
  bats_tmp_dir

  mkdir -p "$BATS_TMP_DIR/fzf"
  printf 'foo▮foo 1.2.3\n'   >  "$BATS_TMP_DIR/fzf/packages-apt"
  printf 'bar▮bar 3.0.0\n' >> "$BATS_TMP_DIR/fzf/packages-apt"
  printf 'foo▮foo 1.2.3\n'   >  "$BATS_TMP_DIR/fzf/packages-apt-installed"
  bats_mock_env "OROSHI_TMP_FOLDER" "$BATS_TMP_DIR"
}

# fzf-source

@test "fzf-source: regenerates cache when missing" {
  rm -f "$BATS_TMP_DIR/fzf/packages-apt" "$BATS_TMP_DIR/fzf/packages-apt-installed"

  # Mock the cache generator to create expected cache files
  apt-packages-cache-generate() {
    printf 'regen▮regen 0.1.0\n' > "$BATS_TMP_DIR/fzf/packages-apt"
    printf 'regen▮regen 0.1.0\n' > "$BATS_TMP_DIR/fzf/packages-apt-installed"
  }
  bats_mock apt-packages-cache-generate

  bats_run_zsh "fzf-apt-packages --source"
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "regen"* ]]
}

@test "fzf-source: outputs all packages from cache" {
  bats_run_zsh "fzf-apt-packages --source"
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "foo"* ]]
  [[ "${lines[1]}" == "bar"* ]]
}

@test "fzf-source: with --installed outputs only installed packages" {
  bats_run_zsh "fzf-apt-packages --source --installed"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "foo▮foo 1.2.3" ]
  [ "${#lines[@]}" -eq 1 ]
}

# fzf-postprocess

@test "fzf-postprocess: extracts package name from selection" {
  bats_run_zsh "printf 'foo▮foo 1.2.3\n' | fzf-apt-packages --postprocess"
  [ "$output" = "foo" ]
}

@test "fzf-postprocess: outputs nothing on empty stdin" {
  bats_run_zsh "printf '' | fzf-apt-packages --postprocess"
  [ "$output" = "" ]
}

@test "fzf-postprocess: handles multi-line selection" {
  bats_run_zsh "printf 'foo▮foo 1.2.3\nbar▮bar 3.0.0\n' | fzf-apt-packages --postprocess"
  [ "${#lines[@]}" -eq 2 ]
  [[ "$output" == *"foo"* ]]
  [[ "$output" == *"bar"* ]]
}

# fzf-options

@test "fzf-options: includes preview command" {
  bats_run_zsh "fzf-apt-packages --options"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--preview=fzf-apt-packages --preview"* ]]
}

# fzf-preview

@test "fzf-preview: shows name, version and description" {
  apt-cache() {
    cat <<'APTEOF'
Package: curl
Version: 7.88.1-10+deb12u8
Description: command line tool for transferring data with URL syntax
 curl is a command line tool for transferring data with URL syntax.
 It supports HTTP, HTTPS, FTP and more.
APTEOF
  }
  apt-is-installed() { return 1; }
  bats_mock apt-cache apt-is-installed

  bats_run_zsh "fzf-apt-packages --preview curl"
  [ "$status" -eq 0 ]
  local stripped="$(bats_strip_ansi "$output")"
  [[ "$stripped" == *"curl"* ]]
  [[ "$stripped" == *"v7.88.1"* ]]
  [[ "$stripped" == *"command line tool"* ]]
}

@test "fzf-preview: shows installed indicator when installed" {
  apt-cache() {
    cat <<'APTEOF'
Package: curl
Version: 7.88.1-10+deb12u8
Description: command line tool
APTEOF
  }
  apt-is-installed() { return 0; }
  bats_mock apt-cache apt-is-installed

  bats_run_zsh "fzf-apt-packages --preview curl"
  [ "$status" -eq 0 ]
  local stripped="$(bats_strip_ansi "$output")"
  [[ "$stripped" == *"Installed"* ]]
}

@test "fzf-preview: handles unknown package gracefully" {
  apt-cache() { return 1; }
  bats_mock apt-cache

  bats_run_zsh "fzf-apt-packages --preview nonexistent-pkg"
  [ "$status" -eq 0 ]
}
