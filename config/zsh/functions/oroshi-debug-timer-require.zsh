local OROSHI_TIMER_REQUIRE_STACK=''

function oroshi-debug-timer-require() {
  [[ $OROSHI_TIMER_REQUIRE_STACK == '' ]] && return

  local separator=":"
  local maxLimit=30
  echo $OROSHI_TIMER_REQUIRE_STACK \
    | sort --reverse --numeric-sort --field-separator=${separator} \
    | head -n $maxLimit \
    | sed 's_/home/tim/.oroshi/config/zsh/__'  \
    | table --separator "${separator}"
}
