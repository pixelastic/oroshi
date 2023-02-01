# We load all the vit functions
# Calling them as zsh functions is way faster than calling them as subshells
function () {
  for functionPath in ~/.oroshi/scripts/bin/vit/bin/functions/*.zsh; do
    source $functionPath
  done
}
