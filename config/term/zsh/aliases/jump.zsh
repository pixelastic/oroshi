# Mark / Jump
# Source: https://jeroenjanssens.com/navigate/

export MARKPATH=$HOME/.marks
alias m='mark'
alias mR='unmark'
alias ml="ls $MARKPATH"
function j { 
  cd -P "${MARKPATH}/$1" 2>/dev/null || echo "No such mark: $1"
}
