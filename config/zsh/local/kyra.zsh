function ok() {
  ~/.oroshi/scripts/deploy/xmodmap # Custom keys
  ~/.oroshi/config/ubuntu/20.04/keybindings/index.zsh # App bindings
  ~/.oroshi/scripts/deploy/xbindkeys # Screen and sound
}

function doctolib-test() {
  cd $(git root);
  rails test $1;
  cd -
}
function doctolib-test-headless() {
  cd $(git root);
  HEADLESS=1 rails test $1;
  cd -
}
alias dt='doctolib-test'
alias dth='doctolib-test-headless'
