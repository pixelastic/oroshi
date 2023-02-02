# Anything defined in this file will be accessible in:
# - Interactive shells (just like zshrc)
# - zsh scripts

# Load functions
# TODO: Only load require.zsh, and have each script require what it needs
for functionPath in ~/.oroshi/config/zsh/functions/**/*.zsh; do
  source $functionPath
done



