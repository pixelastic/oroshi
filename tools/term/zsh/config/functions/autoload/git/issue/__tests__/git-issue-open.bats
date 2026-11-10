bats_load_library 'helper'

setup() {
  bats_tmp_dir

  git-directory-is-github() { return 0; }
  git-directory-url() { echo "https://github.com/pixelastic/my-repo"; }
  bats_mock git-directory-is-github git-directory-url

  # A fake browser records the URL it is called with
  echo '#!/bin/sh' > "$BATS_TMP_DIR/fake-browser"
  echo 'echo "$1" > "'"$BATS_TMP_DIR"'/opened-url.txt"' >> "$BATS_TMP_DIR/fake-browser"
  chmod +x "$BATS_TMP_DIR/fake-browser"
}

@test "opens the issue list when no id is given" {
  bats_run_zsh "BROWSER=$BATS_TMP_DIR/fake-browser && git-issue-open"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/opened-url.txt")" == "https://github.com/pixelastic/my-repo/issues/" ]]
}

@test "opens the issue page when an id is given" {
  bats_run_zsh "BROWSER=$BATS_TMP_DIR/fake-browser && git-issue-open 42"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/opened-url.txt")" == "https://github.com/pixelastic/my-repo/issues/42" ]]
}

@test "stops when not in a GitHub repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "BROWSER=$BATS_TMP_DIR/fake-browser && git-issue-open"
  [[ "$status" -eq 1 ]]
  [[ ! -f "$BATS_TMP_DIR/opened-url.txt" ]]
}

@test "opens the issue of another repo with --repo" {
  git-directory-is-github() { return 1; }
  bats_mock git-directory-is-github

  bats_run_zsh "BROWSER=$BATS_TMP_DIR/fake-browser && git-issue-open 42 --repo pixelastic/imoen"
  [[ "$status" -eq 0 ]]
  [[ "$(cat "$BATS_TMP_DIR/opened-url.txt")" == "https://github.com/pixelastic/imoen/issues/42" ]]
}
