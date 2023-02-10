function zsh-benchmark () {
  local input="$1"

  hyperfine \
    -i \
    "zsh -c '$input'"
}
