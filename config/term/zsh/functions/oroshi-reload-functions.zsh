# Reload all autoloaded functions
# WARNING: Make a copy of this file before editing it.
# WARNING: As it is sourced by zshenv, ALL scripts will run it (including prompts). 
# Any error or output can have consequences.
declare -A OROSHI_AUTOLOADED_FUNCTIONS
declare -A OROSHI_AUTOLOADED_FUNCTIONS_BACKUP

function oroshi-reload-functions() {
  # Autoload functions {{{
  OROSHI_AUTOLOADED_FUNCTIONS_BACKUP=(${(kv)OROSHI_AUTOLOADED_FUNCTIONS})
  OROSHI_AUTOLOADED_FUNCTIONS=()

  # Lazy loading all functions saved in ./autoload
  for item in $ZSH_CONFIG_PATH/functions/autoload/**/*; do
    # If it's a folder, we add it to fpath, so zsh knows where to look
    if [[ -d $item ]]; then
      fpath+=($item)
      continue
    fi

    # If it's a file, we autoload it.
    local functionName="${item:t}"

    # If was already loaded, we unload it, so sourcing this file is idempotent
    if [[ $OROSHI_AUTOLOADED_FUNCTIONS_BACKUP[$functionName] == "1" ]]; then
      unfunction $functionName
    fi

    # Mark it as autoload
    autoload -Uz $functionName
    OROSHI_AUTOLOADED_FUNCTIONS[$functionName]="1"
  done
}
