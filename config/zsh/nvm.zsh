# Usin the zsh-nvm plugin to auto load nvm when changing directories.
export NVM_AUTO_USE=true
source ~/.oroshi/config/zsh/plugins/zsh-nvm/zsh-nvm.plugin.zsh


# Adding yarn globally installed modules to path
if command -v yarn > /dev/null; then
  export PATH=$PATH:"$(yarn global bin)"
fi
