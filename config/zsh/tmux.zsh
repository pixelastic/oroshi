# Pressing Meta-T will fire the terminal, which in turn will fire zsh.
# We'll try to attach to an existing tmux session (or create a new one). Such
# a tmux session will also fire zsh, so in that case we should not try to attach
# to anything and just continue.

# If not inside tmux already and not connected through ssh, then start tmux
if [[ -z "$TMUX" && -z "$SSH_CLIENT" ]]; then
  # (tmux attach || tmux new-session) &>/dev/null
fi
