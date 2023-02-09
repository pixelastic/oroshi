
# Custom shell tools, like nvm, rvm, etc
for toolPath in ~/.oroshi/config/zsh/tools/**/*.zsh; do
  require $toolPath
done


