bats_load_library 'helper'

@test "defaults to reduce when no argument" {
  bats_run_zsh "refactor-start"
  [[ "$status" -eq 0 ]]
  expect_json '.currentWave' 'reduce'
  expect_json '.nextWave' 'rewrite'
}

@test "returns reduce with next rewrite" {
  bats_run_zsh "refactor-start reduce"
  [[ "$status" -eq 0 ]]
  expect_json '.currentWave' 'reduce'
  expect_json '.nextWave' 'rewrite'
}

@test "returns rewrite with next restructure" {
  bats_run_zsh "refactor-start rewrite"
  [[ "$status" -eq 0 ]]
  expect_json '.currentWave' 'rewrite'
  expect_json '.nextWave' 'restructure'
}

@test "returns restructure with null next" {
  bats_run_zsh "refactor-start restructure"
  [[ "$status" -eq 0 ]]
  expect_json '.currentWave' 'restructure'
  expect_json '.nextWave' 'null'
}

@test "fails on invalid wave" {
  bats_run_zsh "refactor-start invalid"
  [[ "$status" -ne 0 ]]
}
