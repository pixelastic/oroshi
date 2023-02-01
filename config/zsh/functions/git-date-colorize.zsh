# Displays a colorized version of a relative date
# Usage:
# $ git-date-colorize "3 months, 2 days ago"             # 3 m., 2d.
# $ git-date-colorize "3 months, 2 days ago" --with-icon #  3m., 2d.
function git-date-colorize() {
  # Filter positional arguments and flags
  local argsp=()
  local -A argsf; argsf=()
  for arg in $argv; do
    [[ "$arg" =~ "^-" ]] && argsf[$arg]=1 || argsp+="$arg"
  done

  # Raw Date {{{
  local rawDate="$argsp[1]"
  # We need a date passed
  if [[ $rawDate == '' ]]; then
    return 0
  fi
  local displayDate="$rawDate"
  displayDate="${displayDate/ ago/}"
  displayDate="${displayDate/ years/y}"
  displayDate="${displayDate/ months/mo}"
  displayDate="${displayDate/ weeks/w}"
  displayDate="${displayDate/ days/d}"
  displayDate="${displayDate/ hours/h}"
  displayDate="${displayDate/ minutes/mn}"
  # }}}

  # If --with-icon is not passed, we simply display the colored date
  if [[ "$argsf[--with-icon]" != 1 ]]; then
    colorize "$displayDate" ALIAS_DATE
    return
  fi

  # Otherwise we add the icon
  colorize " $displayDate" ALIAS_DATE
  return
}
