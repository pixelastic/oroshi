# Rebuild $fpath and autoloaded functions from the given root's autoload dirs
# WARNING: Make a copy of this file before editing it.
# WARNING: As it is sourced by zshenv, ALL scripts will run it (including prompts).
# Any error or output can have consequences.
# Usage:
# $ oroshi-reload-fpath            # Reload from current $ZSH_CONFIG_PATH
# $ oroshi-reload-fpath [root]     # Reload from given root's tools/term/zsh/config/
declare -A OROSHI_AUTOLOADED_FUNCTIONS
declare -A OROSHI_AUTOLOADED_FUNCTIONS_BACKUP
declare -a OROSHI_AUTOLOADED_FPATH

function oroshi-reload-fpath() {
  local configPath="$ZSH_CONFIG_PATH"
  # If a root is provided, derive configPath from it instead
  [[ -n "$1" ]] && configPath="$1/tools/term/zsh/config"

  # Remove previously tracked fpath dirs to allow clean replacement
  local dir
  for dir in $OROSHI_AUTOLOADED_FPATH; do
    fpath=(${fpath:#$dir})
  done
  OROSHI_AUTOLOADED_FPATH=()

  # Autoload functions {{{
  OROSHI_AUTOLOADED_FUNCTIONS_BACKUP=(${(kv)OROSHI_AUTOLOADED_FUNCTIONS})
  OROSHI_AUTOLOADED_FUNCTIONS=()

  # Lazy loading all functions saved in ./autoload
  for item in $configPath/functions/autoload/**/*(N); do
    # If it's a folder, we add it to fpath, so zsh knows where to look
    if [[ -d $item ]]; then
      # Skip all directories starting with __
      [[ $item == */__* ]] && continue

      fpath+=($item)
      OROSHI_AUTOLOADED_FPATH+=($item)
      continue
    fi

    # Skip files with an extension (docs, configs, etc.)
    [[ "${item:e}" != "" ]] && continue

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
