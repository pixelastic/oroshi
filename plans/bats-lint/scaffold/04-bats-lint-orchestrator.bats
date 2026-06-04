#!/usr/bin/env bats

bats_load_library 'helper'

LINTSTAGED_CONFIG="${BATS_TEST_DIRNAME}/../../../lintstaged.config.js"

@test "lintstaged.config.js has **/*.bats key mapped to yarn run lint:bats" {
  run grep -F "'**/*.bats'" "$LINTSTAGED_CONFIG"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"yarn run lint:bats"* ]]
}
