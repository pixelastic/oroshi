# Display the current state of the rebase:
# - How many steps are there
# - commitId of the current commit being rebased
function oroshi-prompt-populate:git_rebase_status() {
  OROSHI_PROMPT_PARTS[git_rebase_status]=""
  (($GIT_DIRECTORY_IS_REPOSITORY)) || return
  git-rebase-in-progress || return

  local rawInfo="$(git-rebase-info-raw)"
  [[ "$rawInfo" == "" ]] && return

  colors-load-definitions
  icons-load-definitions

  local fields=(${(@ps/▮/)rawInfo})
  local stepCurrent=$fields[1]
  local stepMax=$fields[2]
  local headName=$fields[3]
  local onto=$fields[4]

  headName=${headName:11}
  onto=${onto:0:8}

  local headNameColor="$(git-branch-color $headName)"

  local rebaseStatus="%B%F{$COLORS[git-rebase]}$ICONS[git-rebase] ${stepCurrent}/${stepMax}%f%b"
  rebaseStatus+=" %F{$headNameColor}${headName}%f:%F{$COLORS[git-commit]}${onto}%f"
  OROSHI_PROMPT_PARTS[git_rebase_status]="$rebaseStatus"
}
