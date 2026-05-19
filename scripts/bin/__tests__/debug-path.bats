load 'helper'

setup() {
  export TMP_DIRECTORY="$(bats_tmp)"
  mkdir -p "$TMP_DIRECTORY/bin"
  export PATH="$TMP_DIRECTORY/bin:${BATS_TEST_DIRNAME}/../ai:$PATH"
}

teardown() {
  rm -rf "$TMP_DIRECTORY"
}

@test "debug inner zsh path" {
  # Check what PATH zsh sees when started as a script
  zsh -c 'which review-diff > /tmp/inner-which.txt 2>&1 || echo "not found" > /tmp/inner-which.txt; echo "$PATH" > /tmp/inner-path.txt'
}
