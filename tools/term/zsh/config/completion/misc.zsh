# Matcher list {{{
# matcher-list defines how the command line should be completed. It has a very
# obscure syntax that I don't understand very well (even if I read the whole
# documentation and many Stack Overflow questions, I can barely read what it
# does, and I can't write any of it).

# Sources:
# https://stackoverflow.com/a/68794830/285283
#
# The ./sandbox/ folder sitting next to this file contains a dummy set of
# folders and files that act as a fixture for our completion. If I ever change
# the matcher-list definition, I need to make sure it still:
# ✔ cd p<TAB> | cd perso/
# ✔ cd P<TAB> | cd Pictures/
# ✔ cd a-g<TAB> | cd apt-get/
# ✔ cp server<TAB> | cp 2023-04-05-SERVERLESS-paris-meetup.md
# ✔ cp paris<TAB> | suggests 2022-02-01-paris-ai-meetup.md and 2023-04-05-SERVERLESS-paris-meetup.md
#
# Explanation:
# 0 -- vanilla completion (cd a<TAB> => cd abc/)
# 1 -- smart case completion (cd pic<TAB> => cd Pictures/)
# 2 -- word flex completion (cd ag<TABD> => cd apt-get/)
# 3 -- full flex completion (cp server<TAB> => cp 2023-01-02-serverless-meetup.md)
zstyle ':completion:*' matcher-list \
	'' \
	'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' \
	'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{[:lower:][:upper:]}={[:upper:][:lower:]}' \
	'r:|?=** m:{[:lower:][:upper:]}={[:upper:][:lower:]}'
# }}}

# Menu {{{
# Configure the menu to use for suggestions:
# - select: displays a menu with highlightable elements, when pressing tab
# - yes: forces selecting the first element on tab completion
zstyle ':completion:*' menu select
# Group suggestions by type
zstyle ':completion:*' group-name ''
# Use // to separate the description
zstyle ':completion:*' list-separator '//'
# Display results in lines instead of columns
zstyle ':completion:*' list-rows-first true
# Keep suggestions on separate lines, even if they share the same description
zstyle ':completion:*' list-grouped false
# }}}

# Globs {{{
# Wait 10s before rm ./*
setopt RM_STAR_WAIT
# }}}

# Files {{{
# Hidden files should be suggested
setopt GLOB_DOTS
# Do not add symbols after file names to indicate their type (*, @ or /)
unsetopt LIST_TYPES
# }}}
