# Reload all autoloaded functions
# WARNING: Make a copy of this file before editing it.
# WARNING: As it is sourced by zshenv, ALL scripts will run it (including prompts).
# Any error or output can have consequences.
# Usage:
# $ oroshi-reload-functions             # All ~/.oroshi/ autoloaded functions are reloaded
# $ oroshi-reload-functions worktree    # All autoloaded functions of this oroshi worktree are reloaded
declare -A OROSHI_AUTOLOADED_FUNCTIONS
declare -A OROSHI_AUTOLOADED_FUNCTIONS_BACKUP

function oroshi-reload-functions() {
  local configPath="$ZSH_CONFIG_PATH"
  # If 'worktree' is passed, load from the current worktree root instead
  [[ "$1" == "worktree" ]] && configPath="$(git rev-parse --show-toplevel)/config/term/zsh"

  # Autoload functions {{{
  OROSHI_AUTOLOADED_FUNCTIONS_BACKUP=(${(kv)OROSHI_AUTOLOADED_FUNCTIONS})
  OROSHI_AUTOLOADED_FUNCTIONS=()

  # Lazy loading all functions saved in ./autoload
  for item in $configPath/functions/autoload/**/*; do
    # If it's a folder, we add it to fpath, so zsh knows where to look
    if [[ -d $item ]]; then
      # Skip all directories starting with __
      [[ $item == */__* ]] && continue

      fpath+=($item)
      continue
    fi

    # Skip files with an extension (docs, configs, etc.)
    [[ -n ${item:e} ]] && continue

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
