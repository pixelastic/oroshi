local OROSHI_SOURCE_TIMER_STACK=""

function oroshi_debug_source_timer() {
  local separator=":"
  local maxLimit=15
  echo $OROSHI_SOURCE_TIMER_STACK \
    | sort --reverse --numeric-sort --field-separator=${separator} \
    | head -n $maxLimit \
    | table --separator "${separator}"
}
