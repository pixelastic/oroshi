bats_load_library 'helper'

setup() {
  sourcePrefix="source '${OROSHI_ROOT}/tools/term/zsh/config/functions/autoload/git/github/__lib/search-args.zsh'"
}

# Print each gh argument of the builder on its own line
build_args() {
  bats_run_zsh "$sourcePrefix && git-github-search-args $* && printf '%s\n' \"\${reply[@]}\""
}

# -- State --

@test "maps the state to --state, open by default" {
  build_args
  [[ "$status" -eq 0 ]]
  [[ "$output" == $'--state\nopen' ]]
}

@test "maps the given state to --state" {
  build_args --state closed
  [[ "$output" == $'--state\nclosed' ]]
}

# -- Dates --

@test "maps --date-min to a created qualifier" {
  build_args --date-min 2026-01-01T10:00:00Z
  [[ "$output" == *$'--search\ncreated:>=2026-01-01T10:00:00Z'* ]]
}

@test "maps --date-max to a created qualifier" {
  build_args --date-max 2026-02-01T10:00:00Z
  [[ "$output" == *$'--search\ncreated:<=2026-02-01T10:00:00Z'* ]]
}

@test "puts both date qualifiers in one search" {
  build_args --date-min 2026-01-01T10:00:00Z --date-max 2026-02-01T10:00:00Z
  [[ "$output" == *$'--search\ncreated:>=2026-01-01T10:00:00Z created:<=2026-02-01T10:00:00Z' ]]
}

@test "treats a date without a time as midnight UTC" {
  build_args --date-min 2026-01-01 --date-max 2026-02-01
  [[ "$output" == *"created:>=2026-01-01T00:00:00Z created:<=2026-02-01T00:00:00Z" ]]
}

@test "does not add a search without date or query" {
  build_args --state open
  [[ "$output" != *"--search"* ]]
}

# -- Query --

@test "puts the query before the date qualifiers in the search" {
  build_args --query "'login bug'" --date-min 2026-01-01
  [[ "$output" == *$'--search\nlogin bug created:>=2026-01-01T00:00:00Z' ]]
}

@test "uses the query alone as the search" {
  build_args --query "'login bug'"
  [[ "$output" == *$'--search\nlogin bug' ]]
}

# -- Repo --

@test "passes the repo to gh with --repo" {
  build_args --repo pixelastic/imoen
  [[ "$output" == *$'--repo\npixelastic/imoen' ]]
}

@test "does not add --repo when not given" {
  build_args
  [[ "$output" != *"--repo"* ]]
}
