# Ruby
# Display ruby-related information
which rvm &>/dev/null && hasRvm=1

function __prompt-ruby-version() {
  [ ! -v hasRvm ] && return

  # No specified version
  expectedVersionPath="$(git root)/.ruby-version"
  [[ ! -f $expectedVersionPath ]] && return

  currentVersion="$(rvm-prompt v)"
  expectedVersion="$(cat $expectedVersionPath)"

  # Not using the project specific version
  if [[ $currentVersion != $expectedVersion ]]; then
    echo -n "%F{$COLOR[red]} $currentVersion%f"
    echo -n "%F{$COLOR[yellow]}%f"
    echo -n "%F{$COLOR[green]}$expectedVersion %f"
    return
  fi
}
