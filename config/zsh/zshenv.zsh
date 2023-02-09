# Anything defined in this file will be accessible in:
# - Interactive shells (just like zshrc)
# - zsh scripts

# Load functions
# TODO: See autoload
# https://htr3n.github.io/2018/07/faster-zsh/
for functionPath in ~/.oroshi/config/zsh/functions/**/*.zsh; do
  source $functionPath
done
