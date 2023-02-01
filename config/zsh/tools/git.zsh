# We load all the vit functions
function () {
  for functionPath in ~/.oroshi/scripts/bin/vit/bin/functions/*.zsh; do
    echo $functionPath
    source $functionPath
  done
}
