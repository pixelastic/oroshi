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
