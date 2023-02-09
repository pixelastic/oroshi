# Background
# Display flags based on if some process are running in the background (like
# yarn or bundle installs)

# Display install flags
function __prompt-background-flags() {
  # Quick display: do nothing
  if [[ $OROSHI_PROMPT_ENHANCED_MODE == "0" ]]; then
    return
  fi

  yarn-install-in-progress && echo -n "%F{$COLOR_GREEN_8} %f"
  bundle-install-in-progress && echo -n "%F{$COLORS_RED_8} %f"
}
