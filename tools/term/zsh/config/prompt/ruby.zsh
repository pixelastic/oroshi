# Ruby

colors-load-definitions
icons-load-definitions

# Display project ruby version
# - $ICONS[ruby] (red) if no global ruby
# - $ICONS[ruby] (orange) if no global rbenv
# - {nothing} if not a ruby repo (no .ruby-version)
# - $ICONS[ruby] X.Y.Z (red) if local version isn't installed
# - $ICONS[ruby] X.Y.Z (green) if local and current match
function oroshi-prompt-populate:ruby_version() {
  OROSHI_PROMPT_PARTS[ruby_version]=""

  # Not even a system-wide ruby installation
  if [[ ! -v commands[ruby] ]]; then
    OROSHI_PROMPT_PARTS[ruby_version]="%F{$COLORS[error]}$ICONS[ruby] %f"
    return
  fi

  # No Rbenv
  if [[ ! -v commands[rbenv] ]]; then
    OROSHI_PROMPT_PARTS[ruby_version]="%F{$COLORS[warning]}$ICONS[ruby] %f"
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
    OROSHI_PROMPT_PARTS[ruby_version]="%F{$COLORS[success]}$ICONS[ruby] $expectedVersion%f"
    return
  fi

  # Local version is not even installed
  OROSHI_PROMPT_PARTS[ruby_version]="%F{$COLORS[error]}$ICONS[ruby] $expectedVersion%f"
}

# Check if a bundle install is in progress
function oroshi-prompt-populate:bundle_install_in_progress() {
  OROSHI_PROMPT_PARTS[bundle_install_in_progress]=""

  if bundle-install-in-progress; then
    local installing="%F{$COLORS[red-8]}$ICONS[ruby-install-in-progress] %f"
    OROSHI_PROMPT_PARTS[bundle_install_in_progress]="$installing"
  fi
}
