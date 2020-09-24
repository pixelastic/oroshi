function __prompt-ruby-version() {
  # TODO: Rewrite with rbenv instead of RVM
  # # No rvm
  # if ! which rvm &>/dev/null; then
  #   return
  # fi
  # defaultVersion="$(ruby-version-default)"
  # currentVersion="$(rvm-prompt v)"
  # # Default version
  # if [[ $defaultVersion == $currentVersion ]]; then
  #   return
  # fi
  # echo "$FG[pink]  $currentVersion %f"
}
