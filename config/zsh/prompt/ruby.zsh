# Ruby
# Display ruby-related information

# Display project ruby version
# -  (red) if no global ruby
# -  (orange) if no global rbenv
# - {nothing} if not a ruby repo (no .ruby-version)
# -  X.Y.Z (red) if local version isn't installed
# -  X.Y.Z (green) if local and current match
function __prompt-ruby-version() {
  # Quick display: don't display anything
  if [[ $OROSHI_PROMPT_ENHANCED_MODE == "0" ]]; then
    return
  fi

  # Not even a system-wide ruby installation
  if [[ ! -v commands[ruby] ]]; then
    echo -n "%F{$COLOR_ALIAS_ERROR} %f"
    return
  fi

  # No Rbenv
  if [[ ! -v commands[rbenv] ]]; then
    echo -n "%F{$COLOR_ALIAS_WARNING} %f"
    return
  fi

  local rubyVersionPath="$(find-up .ruby-version)"

  # No local version defined
  if [[ $rubyVersionPath == '' ]]; then
    return
  fi

  local expectedVersion="$(<$rubyVersionPath)"

  # Local version is in use
  if rbenv version-name &>/dev/null; then
    echo -n "%F{$COLOR_ALIAS_SUCCESS}  $expectedVersion%f"
    return
  fi

  # Local version is not even installed
  echo -n "%F{$COLOR_ALIAS_ERROR}  $expectedVersion%f"
}
