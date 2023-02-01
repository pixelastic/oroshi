# Displays a colorized version of a distance ahead/behind
# Usage:
# $ git-distance-colorize "[ahead 4]"                  #  4
# $ git-distance-colorize "[behind 1]"                 #  1
# $ git-distance-colorize "[ahead 4, behind 1]"        #  4,  1
function git-distance-colorize() {

  # Message {{{
  local distance="$argv[1]"
  [[ "$distance" == '' ]] && return 0
  # }}}

  local ahead="$(echo "$distance" | sed -n "s/.*ahead \([0-9]*\).*/\1/p")"
  local behind="$(echo "$distance" | sed -n "s/.*behind \([0-9]*\).*/\1/p")"

  local output=()
  [[ "$ahead" != "" ]] && [[ "$ahead" != 0 ]] && output+="$(colorize " $ahead" GREEN)"
  [[ "$behind" != "" ]] && [[ "$behind" != 0 ]] && output+="$(colorize " $behind" RED)"

  echo $output
}
