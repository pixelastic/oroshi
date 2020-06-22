local DEBUG_STARTTIME=$(($(date +%s%N)/1000000))

# Commands in this file will be executed very early in the zsh initialization
# process.

# Completion {{{
# Add path to custom completion methods
# Note: Must be defined before `compinit`
if [ -z "$OROSHI_COMPLETION_ADDED_TO_FPATH" ]; then
  fpath=(~/.oroshi/config/zsh/completion $fpath)
  OROSHI_COMPLETION_ADDED_TO_FPATH=true
fi
autoload -Uz compinit
zmodload zsh/complist
# Regenerate the .zcompdump file only once a day instead at on each new zsh
# window. This takes ~300ms
# See: https://gist.github.com/ctechols/ca1035271ad134841284#gistcomment-2308206
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done
# }}}

local DEBUG_ENDTIME=$(($(date +%s%N)/1000000))
[[ $ZSH_DEBUG == 1 ]] && echo "[debug]: ${0:t}: $(($DEBUG_ENDTIME - $DEBUG_STARTTIME))ms"
