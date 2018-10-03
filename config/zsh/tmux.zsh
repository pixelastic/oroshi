# Pressing Meta-T will fire Termite, which in turn will fire zsh.
# We'll try to attach to an existing tmux session (or create a new one). Such
# a tmux session will also fire zsh, so in that case we should not try to attach
# to anything and just continue.

# Not inside tmux, we will try to attach to an existing session, or create
# a new one
if [[ -z "$TMUX" ]]; then
  (tmux attach || tmux new-session) &>/dev/null
fi
