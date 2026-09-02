bats_load_library 'helper'

@test "oroshi-aliases-precmd enables aliases" {
  bats_run_zsh "
    setopt NO_ALIASES
    add-zsh-hook() { :; }
    source '$BATS_TEST_DIRNAME/../hooks/aliases.zsh'
    oroshi-aliases-precmd
    [[ -o ALIASES ]] && echo 'on' || echo 'off'
  "
  [[ "$status" -eq 0 ]]
  [[ "$output" = "on" ]]
}

@test "oroshi-aliases-preexec disables aliases" {
  bats_run_zsh "
    setopt ALIASES
    add-zsh-hook() { :; }
    source '$BATS_TEST_DIRNAME/../hooks/aliases.zsh'
    oroshi-aliases-preexec
    [[ -o ALIASES ]] && echo 'on' || echo 'off'
  "
  [[ "$status" -eq 0 ]]
  [[ "$output" = "off" ]]
}
