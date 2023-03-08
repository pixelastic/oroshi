# Run all tests
# Exported variables:
# $T_COMMAND: Name of the command being tested
# $T_FIXTURES: Path to the ./fixtures directory next to the test-* command
# $T_SANDBOX: Path to the temporary folder where the test is executed
# $T_NAME: Name of the test being run
# $T_ASSERTS_STATUS: List of all asserts of the test, with their status
# $T_ASSERTS_MESSAGES: List of all asserts of the test, with their message
function assert() {
  # Command being tested
  local callingCommand=${${(@s/:/)${functrace:t}}[1]}
  local T_COMMAND=${${(@s/-/)${callingCommand}}[@]:1}

  # Path to the fixtures directory
  local T_FIXTURES="${functrace:h}/fixtures"

  # Run each test_* function
  for functionName in ${(k)functions}; do
    # Skip if not a test_ function
    [[ $functionName != test_* ]] && continue

    # Create a sandbox folder
    local randomId="$(mktemp --dry-run XXXXXXXXX)"
    local T_SANDBOX="/tmp/test/${T_COMMAND}/${functionName}_${randomId}"
    mkdir -p $T_SANDBOX

    # Default header, unless updated by assert-message
    local T_NAME=$functionName
    # List of passed tests
    local T_ASSERTS_STATUS=()
    local T_ASSERTS_MESSAGES=()

    # We run the test
    # TODO: We need to capture the output of each test, to be able to test
    # against it
    # But we also need to no start a subshell because we need to update
    # variables in the upper scope
    $functionName 1>/dev/null

    # By default, the test is a success, unless one of the asserts failed
    local testStatus="1"
    [[ ! ${T_ASSERTS_STATUS[(i)0]} -gt ${#T_ASSERTS_STATUS} ]] && testStatus="0"

    # Display details of all asserts in case of failed test
    if [[ $testStatus == "0" ]]; then
      colorize "✘ $T_NAME" $COLOR_ALIAS_ERROR
      for ((i = 1; i <= $#T_ASSERTS_STATUS; i++)); do
        local assertStatus=$T_ASSERTS_STATUS[$i]
        local assertMessage=$T_ASSERTS_MESSAGES[$i]
        [[ $assertStatus == "0" ]] && colorize "  $assertMessage" $COLOR_ALIAS_ERROR
        [[ $assertStatus == "1" ]] && colorize "  $assertMessage" $COLOR_ALIAS_SUCCESS
      done
    else
      colorize "✔ $T_NAME" $COLOR_ALIAS_SUCCESS
    fi

    # Cleanup by removing the sandbox directory
    [[ -d $T_SANDBOX ]] && rm -rf $T_SANDBOX
  done

  # TODO: Exit code differently if all tests pass or not
}

# Update the test message
function assert-name() {
  T_NAME="$1"
}
# Test passes
function assert-success() {
  local message="$1"
  T_ASSERTS_STATUS+=("1")
  T_ASSERTS_MESSAGES+=($message)
}
# Test fails
function assert-failure() {
  local message="$1"
  T_ASSERTS_STATUS+=("0")
  T_ASSERTS_MESSAGES+=($message)
}

# Checks that the specified file exists
function assert-file-exists() {
  local filepath="$1"
  local displayFilepath="${filepath//${T_SANDBOX}\//}"

  local message="${2:-File $displayFilepath exists}"

  [[ -r $filepath ]] && assert-success $message && return
  assert-failure $message
}

# Checks that the content of a file is a specific string
function assert-file-content() {
  local filepath="$1"
  local expected="$2"
  local displayFilepath="${filepath//${T_SANDBOX}\//}"

  local actual="$(<$filepath)"
  local message="${3:-$displayFilepath content should be \"$expected\"}"

  [[ "$actual" == "$expected" ]] && assert-success $message && return
  assert-failure $message
}
function assert-not-file-content() {
  local filepath="$1"
  local unexpected="$2"
  local displayFilepath="${filepath//${T_SANDBOX}\//}"

  local actual="$(<$filepath)"
  local message="${3:-$displayFilepath content should not be \"$unexpected\"}"

  [[ "$actual" != "$unexpected" ]] && assert-success $message && return
  assert-failure $message
}


