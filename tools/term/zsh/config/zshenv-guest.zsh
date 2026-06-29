# Anything defined in this file will be accessible in:
# - Interactive shells (just like zshrc)
# - zsh scripts

# Disable the automated loading of compinit in /etc/zsh/zshrc
skip_global_compinit=1

# Root of where we store runtime config
export OROSHI_TMP_FOLDER="$HOME/local/tmp/oroshi"

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

# Allow tests to override anything done previously in this file through mock
if [[ $MOCK_OVERRIDE != "" ]]; then
  source $MOCK_OVERRIDE
fi
