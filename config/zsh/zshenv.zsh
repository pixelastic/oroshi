# Anything defined in this file will be accessible in:
# - Interactive shells (just like zshrc)
# - zsh scripts

# Backup the list
# Clear the main list
# Iterate on found functions; if was in backup, unset it first
# Rebuild the main list


local functionDirectory=~/.oroshi/config/zsh/functions
# Manually loading all functions saved in ./functions
for item in ${functionDirectory}/*.zsh; do
  source $item
done


# Autoload functions {{{
declare -A OROSHI_AUTOLOADED_FUNCTIONS
declare -A OROSHI_AUTOLOADED_FUNCTIONS_BACKUP
OROSHI_AUTOLOADED_FUNCTIONS_BACKUP=(${(kv)OROSHI_AUTOLOADED_FUNCTIONS})
OROSHI_AUTOLOADED_FUNCTIONS=()

# Lazy loading all functions saved in ./autoload
for item in ${functionDirectory}/autoload/**/*; do
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
# }}}

