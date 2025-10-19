# AI-powered prompts
# TODO:
# generate commit message
# do something similar with midjourney
# Update the -shell one to provide more details: https://github.com/TheR1D/shell_gpt/issues/69
#
# Other of interest:
# https://github.com/zahidkhawaja/rusty

alias ?="ai-question"
alias v?="ai-question-editor"
alias \$="ai-shell"
alias _="ai-code"
alias mj="ai-mj"
alias tm="task-master"

alias cursor="gui ~/local/etc/cursor/cursor.AppImage"

# Claude
# Make it use the global node version, circumventing the need to re-install it
# in each project using a different node version
# Also running it in bash, so it doesn't inherit from my custom
# better-{ls,grep,etc} functions that just confuses it
function oroshi_alias_claude() {
  local nodeBinaryDir=$OROSHI_TMP_FOLDER/node/bin
  alias claude="bash -c '${nodeBinaryDir}/node ${nodeBinaryDir}/claude'"

}
oroshi_alias_claude
unfunction oroshi_alias_claude

alias c="claude"
