# Anything defined in this file will be accessible in:
# - Interactive shells (just like zshrc)
# - zsh scripts

# Disable the automated loading of compinit in /etc/zsh/zshrc
skip_global_compinit=1

# Persistent runtime state: survives a reboot. Use for anything that must
# outlive the session (session dumps, caches we want to keep, etc).
export OROSHI_FOLDER_STATE="$HOME/local/tmp/oroshi"

# Discardable runtime cache: lives under /tmp, lost on reboot or the system's
# 30-day age cleanup. Use for throw-away runtime files (sockets, beacons, etc).
export OROSHI_FOLDER_CACHE="/tmp/oroshi"

# Also make the HOSTNAME globally available. Some tools (like Kitty) can use ENV
# variables in their config, but can't call binaries, so having the HOSTNAME
# available allow me to define per-host config easily.
export HOSTNAME="$(hostname)"

# Define $PATH, adding all scripts from OROSHI_ROOT
typeset -aU path
source $OROSHI_ROOT/tools/term/zsh/config/path.zsh
oroshi-reload-path $OROSHI_ROOT

# Define $fpath, adding all autoloaded functions from OROSHI_ROOT
typeset -aU fpath
source $OROSHI_ROOT/tools/term/zsh/config/functions/oroshi-reload-fpath.zsh
oroshi-reload-fpath $OROSHI_ROOT

# Allow tests to override functions by sourcing $MOCK_OVERRIDE
function _load_test_mocks() {
  # No mock file to apply
  [[ "$MOCK_OVERRIDE" == "" ]] && return

  # Re-apply mocks after every command so sourced files can't shadow them
  trap 'builtin source "$MOCK_OVERRIDE"' DEBUG
}
_load_test_mocks
