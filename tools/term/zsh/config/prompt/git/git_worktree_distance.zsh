# Display ahead/behind counts vs main (right prompt, asynchronous)
function oroshi-prompt-populate:git_worktree_distance() {
  OROSHI_PROMPT_PARTS[git_worktree_distance]=""
  (($GIT_DIRECTORY_IS_REPOSITORY)) || return
  (($GIT_DIRECTORY_IS_WORKTREE)) || return

  colors-load-definitions
  icons-load-definitions

  local iconAhead="$ICONS[git-branch-ahead]"
  local iconBehind="$ICONS[git-branch-behind]"

  # Output format: "ahead▮behind" — empty or exit 1 on failure
  local rawDistance="$(git-worktree-distance-raw)"
  [[ "$rawDistance" == "" ]] && return

  local fields=(${(@ps/▮/)rawDistance})
  local ahead=$fields[1]
  local behind=$fields[2]

  # Both 0 means in sync, nothing to display
  [[ "$ahead" == "0" && "$behind" == "0" ]] && return

  local result=""
  [[ "$ahead" != "0" ]] && result+="%F{$COLORS[git-ahead]}${ahead}${iconAhead}%f"
  [[ "$behind" != "0" ]] && [[ "$result" != "" ]] && result+=" "
  [[ "$behind" != "0" ]] && result+="%F{$COLORS[git-behind]}${behind}${iconBehind}%f"

  OROSHI_PROMPT_PARTS[git_worktree_distance]="$result"
}
