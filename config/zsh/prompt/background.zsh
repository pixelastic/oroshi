# Background
# Display flags based on if some process are running in the background (like
# yarn or bundle installs)

# Display install flags
function __prompt-background-flags() {
  yarn-install-in-progress && echo -n "%F{$COLORS[green8]} %f"
  bundle-install-in-progress && echo -n "%F{$COLORS[red8]} %f"
}
