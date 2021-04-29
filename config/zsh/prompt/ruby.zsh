# Ruby
# Display ruby-related information

function __prompt-ruby-version() {
  # Not even a system-wide ruby installation
  if [[ ! -v commands[ruby] ]]; then
    echo -n "%F{$COLORS[red]} %f"
    return
  fi

  # No Rbenv
  if [[ ! -v commands[rbenv] ]]; then
    echo -n "%F{$COLORS[orange]} %f"
    return
  fi

  # No specified version
  expectedVersionPath="$(git root)/.ruby-version"
  [[ ! -f $expectedVersionPath ]] && return

  currentVersion="$(rbenv version-name)"
  expectedVersion="$(cat $expectedVersionPath)"

  # Not using the project specific version
  if [[ $currentVersion != $expectedVersion ]]; then
    echo -n "%F{$COLORS[red]} $currentVersion%f"
    echo -n "%F{$COLORS[yellow]}%f"
    echo -n "%F{$COLORS[green]}$expectedVersion %f"
    return
  fi
}
