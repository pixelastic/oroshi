bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

@test "clean text: produces empty JSON array and exits 0" {
  vale() { printf '{}\n'; }
  bats_mock vale

  local file="$BATS_TMP_DIR/clean.md"
  printf 'Remove the obstacle.\n' > "$file"
  bats_run_zsh "prose-lint $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "text with violations: produces JSON array and exits 1" {
  vale() {
    printf '{"stdin.txt":[{"Action":{"Name":"","Params":null},"Span":[9,12],"Check":"write-good.Weasel","Description":"","Link":"","Message":"weasel word","Severity":"warning","Match":"very","Line":1}]}\n'
  }
  bats_mock vale

  local file="$BATS_TMP_DIR/bad.md"
  printf 'This is very good.\n' > "$file"
  bats_run_zsh "prose-lint $file"
  [[ "$status" -eq 1 ]]
  local count="$(printf '%s' "$output" | jq 'length')"
  [[ "$count" -eq 1 ]]
}

@test "each violation has exactly 5 keys: line, rule, severity, match, message" {
  vale() {
    printf '{"stdin.txt":[{"Action":{"Name":"","Params":null},"Span":[9,12],"Check":"write-good.Weasel","Description":"","Link":"","Message":"weasel word","Severity":"warning","Match":"very","Line":1}]}\n'
  }
  bats_mock vale

  local file="$BATS_TMP_DIR/bad.md"
  printf 'This is very good.\n' > "$file"
  bats_run_zsh "prose-lint $file"
  local keys="$(printf '%s' "$output" | jq -r '.[0] | keys | sort | join(",")')"
  [[ "$keys" == "line,match,message,rule,severity" ]]
}

@test "string argument with violations: produces JSON array and exits 1" {
  vale() {
    printf '{"stdin.txt":[{"Action":{"Name":"","Params":null},"Span":[9,12],"Check":"proselint.Very","Description":"","Link":"","Message":"Remove very.","Severity":"error","Match":"very","Line":1}]}\n'
  }
  bats_mock vale

  bats_run_zsh "prose-lint 'This is very good.'"
  [[ "$status" -eq 1 ]]
  local keys="$(printf '%s' "$output" | jq -r '.[0] | keys | sort | join(",")')"
  [[ "$keys" == "line,match,message,rule,severity" ]]
}

@test "clean string argument: produces empty JSON array and exits 0" {
  vale() { printf '{}\n'; }
  bats_mock vale

  bats_run_zsh "prose-lint 'Remove the obstacle.'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "Vale crash: exits 2 when Vale exits >= 2" {
  vale() {
    printf 'vale: fatal error\n' >&2
    return 2
  }
  bats_mock vale

  local file="$BATS_TMP_DIR/crash.md"
  printf 'Some text.\n' > "$file"
  bats_run_zsh "prose-lint $file"
  [[ "$status" -eq 2 ]]
}

@test "em dash text: real Vale fires oroshi.NoEmDash and exits 1" {
  local file="$BATS_TMP_DIR/emdash.md"
  printf 'Use a hyphen — not an em dash.\n' > "$file"
  bats_run_zsh "prose-lint $file"
  [[ "$status" -eq 1 ]]
  [[ "$(printf '%s' "$output" | jq -r '.[].rule')" == *"oroshi.NoEmDash"* ]]
}

@test "Vale crash: stderr from Vale is printed to the caller" {
  vale() {
    printf 'vale: fatal error\n' >&2
    return 2
  }
  bats_mock vale

  local file="$BATS_TMP_DIR/crash.md"
  printf 'Some text.\n' > "$file"
  bats_run_zsh "prose-lint $file"
  [[ "$output" == *"vale: fatal error"* ]]
}

@test "blog profile: contractions are not flagged" {
  local file="$BATS_TMP_DIR/contractions.md"
  printf 'I don'"'"'t think it'"'"'s a problem.\n' > "$file"
  bats_run_zsh "prose-lint --profile blog $file"
  [[ "$output" != *"oroshi.NoContractions"* ]]
}

@test "oroshi.NoContractions still flags contractions when a profile enables it" {
  local config="$BATS_TMP_DIR/strict.ini"
  printf 'StylesPath = %s/tools/prose/vale/styles\n[*]\nBasedOnStyles = oroshi\noroshi.NoContractions = error\n' "$OROSHI_ROOT" > "$config"
  local file="$BATS_TMP_DIR/contractions.md"
  printf 'I don'"'"'t think it'"'"'s a problem.\n' > "$file"
  bats_run_zsh "vale --config $config --output=JSON $file"
  [[ "$output" == *"oroshi.NoContractions"* ]]
}

@test "blog profile: ordinals are still flagged" {
  local file="$BATS_TMP_DIR/ordinal.md"
  printf 'This is the 1st item in the list.\n' > "$file"
  bats_run_zsh "prose-lint --profile blog $file"
  [[ "$status" -eq 1 ]]
  [[ "$(printf '%s' "$output" | jq -r '.[].rule')" == *"Google.Ordinal"* ]]
}

# -- Burstiness check (runs after Vale, not inside it) --

@test "uniform sentences: adds a burstiness error to the list" {
  vale() { printf '{}\n'; }
  bats_mock vale

  local file="$BATS_TMP_DIR/uniform.md"
  printf 'One two three four. Five six seven eight. Nine ten eleven twelve. Red blue green black. Cat dog bird fish. Sun moon star sky.\n' > "$file"
  bats_run_zsh "prose-lint $file"
  [[ "$status" -eq 1 ]]
  local rule="$(printf '%s' "$output" | jq --raw-output '.[0].rule')"
  [[ "$rule" == "burstiness" ]]
  local severity="$(printf '%s' "$output" | jq --raw-output '.[0].severity')"
  [[ "$severity" == "error" ]]
}

@test "varied sentences: no burstiness error" {
  vale() { printf '{}\n'; }
  bats_mock vale

  local file="$BATS_TMP_DIR/varied.md"
  printf 'Fast. I had already tried it on another project, and now I wanted to compare it with something else entirely. Still no luck. It broke. I fixed the build by removing the cache folder and running the whole thing again from scratch. Done.\n' > "$file"
  bats_run_zsh "prose-lint $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "short text: no burstiness error under the minimum sentence count" {
  vale() { printf '{}\n'; }
  bats_mock vale

  local file="$BATS_TMP_DIR/short.md"
  printf 'One two three. Four five six.\n' > "$file"
  bats_run_zsh "prose-lint $file"
  [[ "$status" -eq 0 ]]
  [[ "$output" == '[]' ]]
}

@test "burstiness error keeps the 5-key violation shape" {
  vale() { printf '{}\n'; }
  bats_mock vale

  local file="$BATS_TMP_DIR/uniform.md"
  printf 'One two three four. Five six seven eight. Nine ten eleven twelve. Red blue green black. Cat dog bird fish. Sun moon star sky.\n' > "$file"
  bats_run_zsh "prose-lint $file"
  local keys="$(printf '%s' "$output" | jq --raw-output '.[0] | keys | join(",")')"
  [[ "$keys" == "line,match,message,rule,severity" ]]
}
