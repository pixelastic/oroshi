#!/usr/bin/env zsh

for testFile in ~/.oroshi/scripts/bin/__tests__/command-in-list/*; do
  bats ${testFile:a}
done
