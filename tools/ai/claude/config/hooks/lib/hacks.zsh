# Hacks: temporary workarounds.

# Print a command without the useless python3 calls Claude sometimes adds before
# the real ones
#
#   python3 - <<'EOF' 2>/dev/null || echo nopython
#   EOF
#   grep -n 'Force every tab' kitty-session-save
#
# Example: a python3 -c 1 between two commands
#   sed -i 's/a/b/' file
#   python3 -c 1 2>/dev/null
#   sed -i 's/c/d/' file
function hacksRemovePythonNoOp() {
  local command="$1"

  # Nothing to remove without python3
  if [[ "$command" != *python3* ]]; then
    print -r -- "$command"
    return 0
  fi

  print -r -- "$command" | perl -0pe '
    my $suffix = qr/(?:[ \t]+2>\/dev\/null)?(?:[ \t]+\|\|[ \t]+(?:echo[ \t]+nopython|true))?/;
    my $inline = qr/-c[ \t]+(?:1|pass)(?![^\s;&|])$suffix(?=[ \t]*(?:&&|;|\n|\z))/;
    my $quote = qr/(?<quote>["\x27]?)/;
    my $heredoc = qr/-[ \t]+<{2}-?$quote(?<delimiter>\w+)\k<quote>$suffix\n\k<delimiter>(?![^\n])/;
    my $call = qr/python3[ \t]+(?:$inline|$heredoc)/;
    my $link = qr/(?:&&|;)/;

    # A call followed by a link: drop both
    s/$call[ \t]*$link[ \t]*//g;
    # A call preceded by a link: drop both
    s/[ \t]*$link[ \t]+$call//g;
    # A call alone on its lines: drop the lines
    s/^[ \t]*$call[ \t]*\n?//mg;
  '
}
