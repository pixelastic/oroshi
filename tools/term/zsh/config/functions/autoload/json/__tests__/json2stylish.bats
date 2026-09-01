bats_load_library 'helper'

@test "empty array: no output, exits 0" {
  bats_run_zsh "json2stylish" <<<'[]'
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "single file with violations: file header + indented violations, exits 1" {
  local input='[
    {"file":"/src/app.go","code":"unused","level":"error","line":3,"column":5,"message":"var x is unused"}
  ]'
  bats_run_zsh "json2stylish" <<<"$input"
  [[ "$status" -eq 1 ]]
  # File header (absolute path when no --root)
  [[ "$output" == *"/src/app.go"* ]]
  # Violation line
  [[ "$output" == *"3:5"* ]]
  [[ "$output" == *"error"* ]]
  [[ "$output" == *"var x is unused"* ]]
  [[ "$output" == *"unused"* ]]
}

@test "multi-file violations: grouped by file, separated by blank line, exits 1" {
  local input='[
    {"file":"/src/a.go","code":"unused","level":"error","line":1,"column":1,"message":"unused a"},
    {"file":"/src/b.go","code":"unused","level":"error","line":2,"column":3,"message":"unused b"}
  ]'
  bats_run_zsh "json2stylish" <<<"$input"
  [[ "$status" -eq 1 ]]
  # Both files appear as headers
  [[ "$output" == *"/src/a.go"* ]]
  [[ "$output" == *"/src/b.go"* ]]
  # Blank line separates file groups (header + violation + blank + header + violation)
  local lineCount="$(printf '%s\n' "$output" | wc -l)"
  [[ "$lineCount" -ge 5 ]]
}

@test "column alignment: line:column and level right-padded to max width within group" {
  local input='[
    {"file":"/src/test.go","code":"SC2086","level":"error","line":3,"column":10,"message":"Missing double quotes"},
    {"file":"/src/test.go","code":"SC2154","level":"warn","line":100,"column":1,"message":"Variable not assigned"}
  ]'
  bats_run_zsh "json2stylish" <<<"$input"
  [[ "$status" -eq 1 ]]
  # Level column starts at the same byte offset in both violation lines
  local line1="$(printf '%s\n' "$output" | grep 'error')"
  local line2="$(printf '%s\n' "$output" | grep 'warn')"
  local pos1="$(printf '%s' "$line1" | grep -bo 'error' | head -1 | cut -d: -f1)"
  local pos2="$(printf '%s' "$line2" | grep -bo 'warn' | head -1 | cut -d: -f1)"
  [[ "$pos1" -eq "$pos2" ]]
}

@test "--root: strips prefix from file paths in output" {
  local input='[
    {"file":"/home/tim/project/src/app.go","code":"unused","level":"error","line":3,"column":5,"message":"var x is unused"}
  ]'
  bats_run_zsh "json2stylish --root /home/tim/project/" <<<"$input"
  [[ "$status" -eq 1 ]]
  # File header shows relative path
  [[ "$output" == *"src/app.go"* ]]
  # Absolute prefix is stripped
  [[ "$output" != *"/home/tim/project/"* ]]
}
