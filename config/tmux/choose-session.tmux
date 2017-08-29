# This will display the tree of all sessions and windows, collapsed by default,
# in full screen

# Make it full screen if we're not yet in fullscreen mode
run "tmux-maximize"

# Choose between all the sessions and windows. Use choose-tree to have it
# expanded by default
choose-session

# bind-key -n M-s resize-pane -Z \; choose-session
# choose-session -c "resize-pane -Z \; select-window -t '%%'"
# bind-key -n M-s choose-session
