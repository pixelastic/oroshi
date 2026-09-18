bats_load_library 'helper'

setup() {
  bats_tmp_dir
}

# fzf-source

@test "fzf-source: exits with status 0" {
  bats_run_zsh "ctrl-b --source"
  [[ "$status" -eq 0 ]]
}

@test "fzf-source: outputs at least one command name" {
  bats_run_zsh "ctrl-b --source"
  [[ "${#lines[@]}" -gt 0 ]]
}

@test "fzf-source: each line contains exactly one command name" {
  bats_run_zsh "ctrl-b --source"
  local line
  for line in "${lines[@]}"; do
    [[ "$line" != *" "* ]]
  done
}

@test "fzf-source: excludes underscore-prefixed entries" {
  bats_run_zsh "ctrl-b --source"
  local line
  for line in "${lines[@]}"; do
    [[ "$line" != _* ]]
  done
}

@test "fzf-source: excludes TRAP entries" {
  bats_run_zsh "ctrl-b --source"
  [[ "$output" != *$'\n'"TRAP"* ]]
}

@test "fzf-source: excludes dash-prefixed entries" {
  bats_run_zsh "ctrl-b --source"
  local line
  for line in "${lines[@]}"; do
    [[ "$line" != -* ]]
  done
}

# fzf-options

@test "fzf-options: includes --prompt with Commands label" {
  bats_run_zsh "ctrl-b --options"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"--prompt="* ]]
  [[ "$output" == *"Commands"* ]]
}

@test "fzf-options: includes preview command" {
  bats_run_zsh "ctrl-b --options"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"--preview=bin-zsh ctrl-b --preview"* ]]
}

# fzf-preview

@test "fzf-preview: shows type and which output for a function" {
  bats_run_zsh "ctrl-b --preview ctrl-b"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"function"* ]]
}

@test "fzf-preview: shows builtin with header and description" {
  bats_run_zsh "ctrl-b --preview echo"
  [[ "$status" -eq 0 ]]
  local stripped="$(bats_strip_ansi "$output")"
  [[ "$stripped" == *"echo"* ]]
  [[ "$stripped" == *"shell builtin"* ]]
  [[ "$stripped" == *"display a line of text"* ]]
}

@test "fzf-preview: shows colored path for external command" {
  bats_run_zsh "ctrl-b --preview cat"
  [[ "$status" -eq 0 ]]
  local stripped="$(bats_strip_ansi "$output")"
  [[ "$stripped" == *"/usr/"* ]] || [[ "$stripped" == *"/bin/"* ]]
  [[ "$stripped" == *"cat"* ]]
}

@test "fzf-preview: shows oroshi command with header and file content" {
  # bin-zsh is a real command under OROSHI_ROOT
  bats_run_zsh "ctrl-b --preview bin-zsh"
  [[ "$status" -eq 0 ]]
  local stripped="$(bats_strip_ansi "$output")"
  [[ "$stripped" == *"bin-zsh"* ]]
  [[ "$stripped" == *"oroshi command"* ]]
  # bat adds line numbers to file content
  [[ "$stripped" == *"#!/usr/bin/env zsh"* ]]
}

@test "fzf-preview: shows alias expansion for aliases" {
  bats_run_zsh "ctrl-b --preview which-command"
  [[ "$status" -eq 0 ]]
  local stripped="$(bats_strip_ansi "$output")"
  [[ "$stripped" == *"alias"* ]]
  [[ "$stripped" == *"→"* ]]
}

@test "fzf-preview: shows type label on separate line from name" {
  bats_run_zsh "ctrl-b --preview colors-build"
  [[ "$status" -eq 0 ]]
  local stripped="$(bats_strip_ansi "$output")"
  # First line is name, second line is type
  local firstLine="${lines[0]}"
  local strippedFirst="$(bats_strip_ansi "$firstLine")"
  [[ "$strippedFirst" == *"colors-build"* ]]
  [[ "$strippedFirst" != *"autoloaded function"* ]]
}

@test "fzf-preview: shows bat output for oroshi autoloaded function" {
  bats_run_zsh "ctrl-b --preview colors-build"
  [[ "$status" -eq 0 ]]
  local stripped="$(bats_strip_ansi "$output")"
  [[ "$stripped" == *"autoloaded function"* ]]
  # bat adds line numbers
  [[ "$stripped" == *"1"* ]]
}

@test "fzf-preview: shows zsh system function label and comment" {
  bats_run_zsh "ctrl-b --preview colors"
  [[ "$status" -eq 0 ]]
  local stripped="$(bats_strip_ansi "$output")"
  [[ "$stripped" == *"zsh system function"* ]]
  [[ "$stripped" == *"ANSI"* ]]
}

@test "fzf-preview: shows description for external command via binary-describe" {
  bats_run_zsh "ctrl-b --preview cat"
  [[ "$status" -eq 0 ]]
  local stripped="$(bats_strip_ansi "$output")"
  [[ "$stripped" == *"concatenate"* ]]
}

@test "fzf-preview: exits 0 for unknown command" {
  bats_run_zsh "ctrl-b --preview nonexistent-command-xyz-123"
  [[ "$status" -eq 0 ]]
}

# fzf-postprocess

@test "fzf-postprocess: outputs command name from stdin" {
  bats_run_zsh "echo 'ls' | ctrl-b --postprocess"
  [[ "$output" = "ls" ]]
}

@test "fzf-postprocess: outputs nothing on empty stdin" {
  bats_run_zsh "printf '' | ctrl-b --postprocess"
  [[ "$output" = "" ]]
}
