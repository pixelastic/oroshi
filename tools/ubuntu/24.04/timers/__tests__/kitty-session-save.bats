bats_load_library 'helper'

setup() {
  CONFIG_DIRECTORY="$BATS_TEST_DIRNAME/../config"
  SERVICE="$CONFIG_DIRECTORY/kitty-session-save.service"
  TIMER="$CONFIG_DIRECTORY/kitty-session-save.timer"
}

# Print the value of a unit file key, e.g. unit_value Type file.service
unit_value() {
  grep --max-count=1 "^$1=" "$2" | cut --delimiter='=' --fields=2-
}

@test "service runs kitty-session-save once through an absolute bin-zsh" {
  [[ "$(unit_value Type "$SERVICE")" == "oneshot" ]]

  # Resolve the %h specifier like systemd does
  local execStart="$(unit_value ExecStart "$SERVICE")"
  execStart="${execStart//%h/$HOME}"
  local binary="${execStart%% *}"
  local args="${execStart#* }"

  [[ "$binary" == /* ]]
  [[ "$binary" == */scripts/bin/bin-zsh ]]
  [[ -x "$binary" ]]
  [[ "$args" == "kitty-session-save" ]]
}

@test "timer fires two minutes after startup then every two minutes" {
  [[ "$(unit_value OnStartupSec "$TIMER")" == "2min" ]]
  [[ "$(unit_value OnUnitActiveSec "$TIMER")" == "2min" ]]
  [[ "$(unit_value WantedBy "$TIMER")" == "timers.target" ]]
}
