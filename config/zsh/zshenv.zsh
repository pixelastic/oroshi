# Anything defined in this file will be accessible in:
# - Interactive shells (just like zshrc)
# - zsh scripts

# Load functions
for functionPath in ~/.oroshi/config/zsh/functions/**/*.zsh; do
  source $functionPath
done



