# Start nvm if nvm is installed
export NVM_DIR="$HOME/.nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  source "$NVM_DIR/nvm.sh"
  # Installing packages globally with `npm install -g` correctly put them in the
  # nvm binary folder
  # Installing the same with yarn will put them all in $(yarn global bin)
  # https://github.com/yarnpkg/yarn/issues/1321
  if command -v yarn > /dev/null; then
    export PATH=$PATH:~/.config/yarn/global/node_modules/.bin
  fi
fi
