# shellcheck disable=SC1094
# To debug performance issue, uncomment the following lines:
# - zmodload zsh/zprof at the top of the file
# - zprof at the end
# zmodload zsh/zprof

# Another way to evaluate performance is to benchmark zsh loading time with
# hyperfine --warmup 3 "zsh -i -c exit"
# Target should be under 150ms

source $ZSH_CONFIG_PATH/env.zsh           # Global environment variables
source $ZSH_CONFIG_PATH/tmux.zsh          # Tmux load
source $ZSH_CONFIG_PATH/theming/index.zsh # Colors

source $ZSH_CONFIG_PATH/history.zsh           # History of commands
source $ZSH_CONFIG_PATH/aliases/index.zsh     # Aliases definitions
source $ZSH_CONFIG_PATH/tools/index.zsh       # Tools (nvm, bat, rg, fzf, etc) configuration
source $ZSH_CONFIG_PATH/keybindings/index.zsh # Ctrl-G, Ctrl-P, etc
source $ZSH_CONFIG_PATH/completion/index.zsh  # Autocompletion
source $ZSH_CONFIG_PATH/prompt/index.zsh      # Prompt display

source $ZSH_CONFIG_PATH/local/index.zsh # Laptop-specific configuration

# zprof
