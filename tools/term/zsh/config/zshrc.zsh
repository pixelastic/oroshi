# shellcheck disable=SC1094
# To debug performance issue, uncomment the following lines:
# - zmodload zsh/zprof at the top of the file
# - zprof at the end
# zmodload zsh/zprof

# Another way to evaluate performance is to benchmark zsh loading time with
# hyperfine --warmup 3 "zsh -i -c exit"
# Target should be under 150ms

source $OROSHI_ROOT/tools/term/zsh/config/env.zsh           # Global environment variables
source $OROSHI_ROOT/tools/term/zsh/config/init.zsh          # Shell initialization
source $OROSHI_ROOT/tools/term/zsh/config/theming/index.zsh # Colors

source $OROSHI_ROOT/tools/term/zsh/config/history.zsh           # History of commands
source $OROSHI_ROOT/tools/term/zsh/config/aliases/index.zsh     # Aliases definitions
source $OROSHI_ROOT/tools/term/zsh/config/tools/index.zsh       # Tools (nvm, bat, fzf, etc)
source $OROSHI_ROOT/tools/term/zsh/config/keybindings/index.zsh # Ctrl-G, Ctrl-P, etc
source $OROSHI_ROOT/tools/term/zsh/config/completion/index.zsh  # Autocompletion
source $OROSHI_ROOT/tools/term/zsh/config/prompt/index.zsh      # Prompt display

source $OROSHI_ROOT/tools/term/zsh/config/local/index.zsh # Laptop-specific configuration

# zprof
