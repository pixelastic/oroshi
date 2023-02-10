# Anything defined in this file will be accessible in:
# - Interactive shells (just like zshrc)
# - zsh scripts

local functionDirectory=~/.oroshi/config/zsh/functions
# Manually loading all functions saved in ./functions
for item in ${functionDirectory}/*.zsh; do
  source $item
done
# Lazy loading all functions saved in ./autoload
for item in ${functionDirectory}/autoload/**/*; do
  # If it's a folder, we add it to fpath, so zsh knows where to look
  if [[ -d $item ]]; then
    fpath+=($item)
    continue
  fi

  # If it's a file, we mark the function as autoloadable, so zsh replaces it
  # with a lazy-loaded
  autoload -Uz ${item:t}
done

