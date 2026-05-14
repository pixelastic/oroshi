# Unset hook-injected git env vars — runs on load, affects all tests in the file
unset GIT_DIR GIT_INDEX_FILE GIT_OBJECT_DIRECTORY GIT_WORK_TREE

# Run a zsh autoloaded function
# Note: As bats is bash, and doesn't support zsh by default, we need to wrap the
# call to zsh autoloaded functions in a zsh -c
run_zsh_fn() {
  local func="${1}"
  shift
  run zsh -c "${func} \"\$@\"" -- "$@"
}

# Create and return a predictable tmp dir for the current bats test
# Path: /tmp/oroshi/bats/<test-file>/<slugified-test-name>
bats_tmp() {
  # Get the test file name
  local file="${BATS_TEST_FILENAME##*/}"
  file="${file%.bats}"

  # Get the slug of the test name
  local slug
  slug="$(zsh -c 'slugify "$1"' -- "${BATS_TEST_NAME}")"

  # Create the tmp dir
  local dir="/tmp/oroshi/bats/${file}/${slug}"
  rm -rf "$dir"
  mkdir -p "$dir"

  # Return it
  echo "$dir"
}
