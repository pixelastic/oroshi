# Fancy prompt.

# init
setopt PROMPT_SUBST
autoload -U promptinit
promptinit

# Left part
# user@host:/path/ %
PROMPT='$promptUsername@$promptHostname:$(getPromptPath) $(getPromptHash) '

# User
promptUsername="$FG[$promptColor[username]]%n$FX[reset]"

# Hostname
promptHostname="$FG[$promptColor[hostname]]%m$FX[reset]"

# Path
# getPromptPath() {{{
# This will return a formatted path.
# - If more than 4 directories, will only keep the first and the last two
# - Will prepend a ! and display it in red if not writable
function getPromptPath() {
	local promptPath=$PWD
	local splitPath
	splitPath=(${(s:/:)PWD})

	# Keep only first and last dirs if too long
	if [[ ${#splitPath[*]} -ge 4 ]]; then
		promptPath=/${splitPath[1]}/../${splitPath[-2]}/${splitPath[-1]}/
	fi

	# Prefix a ! if not writable
	if [[ ! -w $PWD ]]; then
		promptPath=!$promptPath
	fi

  # Checking if I'm the owner or am in the group of this dir
  local promptPathColor=$promptColor[pathRestricted]
  if [[ $UID = $(stat --print "%u" $PWD) ]]; then
    # I'm the owner
    promptPathColor=$promptColor[pathOwner]
    else
      local pathGroup=$(stat --print "%G" $PWD)
      local userGroups="($(groups $USER))"
      if [[ $userGroups =~ $pathGroup ]]; then
        # I'm in the group
        promptPathColor=$promptColor[pathGroup]
      fi
	fi

  echo "$FG[$promptPathColor]$promptPath$FX[reset]"
}
# }}}

# Directory indicator
# getPromptHash() {{{
function getPromptHash() {
  local promptHashColor=''
  local promptHash='%#'

  if [[ $promptIsGit = 1 ]]; then
    echo $(getPromptHashGit)
    return
  fi

  echo "$FG[$promptHashColor]$promptHash$FX[reset]"
}
# }}}
# getPromptHashGit() {{{
function getPromptHashGit() {
	local gitStatus="$(git status-short)"
  local promptHashColor=$promptColor[repoClean]
	local promptHash='±'

	# Does it have modified or new files ?
  local gitHasModifiedFiles=0
	if [[ $gitStatus =~ ' . ' || $gitStatus =~ '\?\?' ]]; then
		gitHasModifiedFiles=1
	fi

	# Does it have staged files ?
  local gitHasStagedFiles=0
	if [[ $gitStatus =~ '.  ' ]]; then
		gitHasStagedFiles=1
	fi

	# Repo is clean, but there are files in the index waiting for a commit
	if [[ $gitHasModifiedFiles = 0 && $gitHasStagedFiles = 1 ]]; then
		promptHashColor=$promptColor[repoStaged]
		promptHash="${promptHash}*"
	fi

	# Files have been changed or added, but nothing is ready to be commited
	if [[ $gitHasModifiedFiles = 1 && $gitHasStagedFiles = 0 ]]; then
		promptHashColor=$promptColor[repoDirty]
	fi

	# Files have been added/modified and others are ready to be comitted
	if [[ $gitHasModifiedFiles = 1 && $gitHasStagedFiles = 1 ]]; then
		promptHashColor=$promptColor[repoDirtyAndStaged]
		promptHash="${promptHash}*"
	fi

  echo "$FG[$promptHashColor]$promptHash$FX[reset]"
}
# }}}


# chpwd() {{{
# Note: This is automatically called by the prompt whenever we change
# directories
function chpwd() {
  promptIsGit=$(isGit)
  
	# Window title
	print -Pn "\e]2;%n@%m:%~/\a"
}
# }}}

# isGit() {{{
function isGit() {
  if [[ $(git --work-tree="$PWD" status 2>/dev/null) != '' ]]; then
    echo 1
  else
    echo 0
  fi
}
# }}}
return


# return



# Debug functions
# promptDebug() {{{
# Note: Update the global promptDebug var which is printed on every prompt
function promptDebug() {
promptDebug="
$1
"
}
# }}}

# Helper functions
# getRepoRoot() {{{
function getRepoRoot() {
	# Git
	if [[ $versionSystem = 'git' ]]; then
		echo $(git root)
		return
	fi
	# Hg
	if [[ $versionSystem = 'hg' ]]; then
		echo $(hg --cwd "$PWD" root 2>/dev/null)
		return
	fi
}
# }}}
# getPromptPath() {{{
# Returns a path that can be displayed in the prompt. Will only keep the first
# dir in the path as well as the last two, and fill with dots in the middle
function getPromptPath() {
	local promptPath=$PWD
	local splitPath
	splitPath=(${(s:/:)PWD})

	# Keep only first and last dirs if too long
	if [[ ${#splitPath[*]} -ge 4 ]]; then
		promptPath=/${splitPath[1]}/../${splitPath[-2]}/${splitPath[-1]}/
	fi

	# Prefix a ! if not writable
	if [[ ! -w $PWD ]]; then
		promptPath=!$promptPath
	fi

	echo $promptPath
}
# }}}
# getPromptPathColor() {{{
function getPromptPathColor() {
	# Checking if I'm the owner
	local pathOwner=$(stat --print "%u" $PWD)
	if [[ $UID = $pathOwner ]]; then
		echo $promptColor[pathOwner]
		return
	fi

	# Checking if I'm in the group
	local pathGroup=$(stat --print "%G" $PWD)
	local userGroups="($(groups $USER))"
	if [[ $userGroups =~ $pathGroup ]]; then
		echo $promptColor[pathGroup]
		return
	fi

	# I have no special privilege
	echo $promptColor[pathRestricted]
return
}
# }}}
# expandCommandAlias() {{{
function expandCommandAlias() {
	local argCommand=$1
	local alias="$(alias $argCommand)"
	# No alias
	if [[ ! $alias =~ '^.*=.*' ]]; then
		echo $argCommand
		return
	fi

	# Note: We need two regexp to check the alias value depending if the alias
	# contains a space or not (in which case it is enclosed in quotes)
	if [[ $alias =~ ' ' ]]; then
		local aliasCommand="$(echo $alias | sed -r "s/.*='(.*)'/\1/g")"
	else
		local aliasCommand="$(echo $alias | sed -r "s/.*=(.*)/\1/g")"
	fi

	echo $aliasCommand
}
# }}}
# expandGitAlias() {{{
function expandGitAlias() {
	local gitCommand=$1
	local aliasCommand="`git config alias.$gitCommand`"
	# No alias
	if [[ $aliasCommand = '' ]]; then
		echo $gitCommand
		return
	fi
	# Alias expands to an external command
	# Note: We stop if that is the case. We do not handle this edge case so far.
	if [[ $aliasCommand[1] = '!' ]]; then
		echo $gitCommand
		return
	fi

	# We return the expanded git alias
	echo $aliasCommand
}
# }}}
# expandHgAlias() {{{
function expandHgAlias() {
	local hgCommand=$1
	local alias="`hg showconfig | grep '^alias.'$hgCommand`"
	# No alias
	if [[ $alias = '' ]]; then
		echo $hgCommand
		return
	fi

	# We parse the alias to find the real commands being executed
	local aliasCommand="`echo $alias | sed -r "s/.*=(.*)/\1/g"`"

	# Alias expands to an external command
	# Note: We stop if that is the case. We do not handle this edge case so far.
	if [[ $aliasCommand[1] = '!' ]]; then
		echo $hgCommand
		return
		# aliasCommand=${aliasCommand[2,$]}
		# aliasCommand=${aliasCommand//\$HG/hg}
	fi

	# We return the expanded hg command
	echo $aliasCommand
}
# }}}
# setPreviousCommand() {{{
# Set $previousCommand as a global array
function setPreviousCommand() {
	# Split list command as an array, separated by spaces
	local arrCommand
	arrCommand=(${(s: :)1})

	# We expand terminal aliases
	local commandAlias="$(expandCommandAlias $arrCommand[1])"
	if [[ $commandAlias != $arrCommand[1] ]]; then
		shift arrCommand
		arrCommand=($commandAlias $arrCommand)
		arrCommand=(${(s: :)arrCommand})
	fi
	
	# We expand hg/git aliases
	if [[ $arrCommand[1] = 'git' || $arrCommand[1] = 'hg' ]]; then
		local versionType=$arrCommand[1]
		local versionMethod=$arrCommand[2]
		local versionMethodAlias=''
		
		if [[ $versionType = 'git' ]]; then
			versionMethodAlias="$(expandGitAlias $versionMethod)"
		fi
		if [[ $versionType = 'hg' ]]; then
			versionMethodAlias="$(expandHgAlias $versionMethod)"
		fi

		# Recompose the full command by replacing the alias
		if [[ $versionMethodAlias != '' && $versionMethodAlias != $versionMethod ]]; then
			shift arrCommand
			shift arrCommand
			arrCommand=($versionType $versionMethodAlias $arrCommand)
			arrCommand=(${(s: :)arrCommand})
		fi
	fi

	# We update the global previousCommand
	previousCommand=($arrCommand)
}
# }}}

# Update display
# updatePromptGit() {{{
function updatePromptGit() {
	updateHashGit
	updateTagGit
	updateSubmoduleGit
	updateBranchGit
	updatePushIndicatorGit
}
# }}}
# updateAliases() {{{
function updateAliases() {
	# Load an alias file for this vcs if exists, otherwise unset them.
	local aliasFilePrefix=~/.oroshi/config/zsh/aliases
	local aliasFile=${aliasFilePrefix}-${versionSystem}.zsh
	local aliasFileDefault=${aliasFilePrefix}-none.zsh

	if [[ -r $aliasFile ]]; then
		source $aliasFile
	else
		source $aliasFileDefault
	fi
}
# }}}
# updateHash() {{{
function updateHash() {
	if [[ $versionSystem = 'git' ]]; then
		updateHashGit
		return
	fi
	if [[ $versionSystem = 'hg' ]]; then
		updateHashHg
		return
	fi
	# No special hash
	colorHash=''
	hashSymbol='%#'
}
# }}}
# updateHashGit() {{{
function updateHashGit() {
	# Stop if not a git repo
	if [[ $versionSystem != 'git' ]]; then
		return
	fi

	# Default values
	hashSymbol='±'
	colorHash=$promptColor[gitClean]

	local gitStatus="$(git status-short)"

	# Does it have modified or new files ?
	if [[ $gitStatus =~ ' . ' || $gitStatus =~ '\?\?' ]]; then
		local gitHasModifiedFiles=1
	else
		local gitHasModifiedFiles=0
	fi

	# Does it have staged files ?
	if [[ $gitStatus =~ '.  ' ]]; then
		gitHasStagedFiles=1
	else
		gitHasStagedFiles=0
	fi

	# Repo is clean, but there are files in the index waiting for a commit
	if [[ $gitHasModifiedFiles = 0 && $gitHasStagedFiles = 1 ]]; then
		colorHash=$promptColor[gitStaged]
		hashSymbol="${hashSymbol}*"
		return
	fi

	# Files have been changed or added, but nothing is ready to be commited
	if [[ $gitHasModifiedFiles = 1 && $gitHasStagedFiles = 0 ]]; then
		colorHash=$promptColor[gitDirty]
		return
	fi

	# Files have been added/modified and others are ready to be comitted
	if [[ $gitHasModifiedFiles = 1 && $gitHasStagedFiles = 1 ]]; then
		colorHash=$promptColor[gitDirtyAndStaged]
		hashSymbol="${hashSymbol}*"
		return
	fi
}
# }}}
# updateHashHg() {{{
function updateHashHg() {
	# Stop if not an hg repo
	if [[ $versionSystem != 'hg' ]]; then
		return
	fi

	# Default symbol
	hashSymbol='☿'

	local hgStatus="$(hg status)"

	# Appending a ~ if untracked changes
	if [[ $hgStatus =~ '\?' ]]; then
		hashSymbol="${hashSymbol}~"
	fi

	# Changing color if repo clean or waiting for commit
	if [[ $hgStatus = '' ]]; then
		colorHash=$promptColor[hgClean]
	else
		colorHash=$promptColor[hgDirty]
	fi
}
# }}}
# updateTag() {{{
function updateTag() {
	if [[ $versionSystem = 'git' ]]; then
		updateTagGit
		return
	fi
	# No special tag
	promptTag=''
	colorTag=''
}
# }}}
# updateTagGit() {{{
function updateTagGit() {
	# Stop if not a git repo
	if [[ $versionSystem != 'git' ]]; then
		return
	fi

	# Setting the tag
	local shortTag
	shortTag=$(git current-tag)
	promptTag="$shortTag "

	# Tag will be differently colored if we are exactly at that tag, or later on
	local fullTag
	fullTag=$(git describe --tags 2>/dev/null)
	if [[ $shortTag = $fullTag ]]; then
		colorTag=$promptColor[tagExact]
	else
		colorTag=$promptColor[tag]
	fi
}
# }}}
# updateSubmodule() {{{
function updateSubmodule() {
	if [[ $versionSystem = 'git' ]]; then
		updateSubmoduleGit
		return
	fi
	# No special submodule
	promptSubmodule=''
	colorSubmodule=''
}
# }}}
# updateSubmoduleGit() {{{
function updateSubmoduleGit() {
	# Stop if not a git repo
	if [[ $versionSystem != 'git' ]]; then
		return
	fi

	local isSubmodule="$(git is-submodule)"

	# No parent root
	if [[ $isSubmodule = 0 ]]; then
		promptSubmodule=''
		colorSubmodule=''
		return
	fi

	# Add symbol and coloring
	promptSubmodule='↯ '
	colorSubmodule=$promptColor[submodule]
}
# }}}
# updateBranch() {{{
function updateBranch() {
	if [[ $versionSystem = 'git' ]]; then
		updateBranchGit
		return
	fi
	# No special branch
	promptBranch=''
	colorBranch=''
}
# }}}
# updateBranchGit() {{{
function updateBranchGit() {
	# Stop if not a git repo
	if [[ $versionSystem != 'git' ]]; then
		return
	fi

	promptBranch=$(git current-branch)
	# No branch found
	if [[ promptBranch = '' ]]; then
		colorBranch=''
		return
	fi

	# Master branch
	if [[ $promptBranch = 'master' ]]; then
		colorBranch=$promptColor[gitFlowMaster]
		return
	fi
	# Hotfix branch
	if [[ $promptBranch =~ '^hotfix/' ]]; then
		promptBranch=${promptBranch/hotfix\//}
		colorBranch=$promptColor[gitFlowHotfix]
		return
	fi
	# Release branch
	if [[ $promptBranch =~ '^release/' ]]; then
		promptBranch=${promptBranch/release\//}
		colorBranch=$promptColor[gitFlowRelease]
		return
	fi
	# Develop branch
	if [[ $promptBranch = 'develop' ]]; then
		colorBranch=$promptColor[gitFlowDevelop]
		return
	fi
	# Bugfix branch
	if [[ $promptBranch =~ '^feature/bugfix/' ]]; then
		promptBranch=${promptBranch/feature\/bugfix\//}
		colorBranch=$promptColor[gitFlowBugfix]
		return
	fi
	# Feature branch
	if [[ $promptBranch =~ '^feature/' ]]; then
		promptBranch=${promptBranch/feature\//}
		colorBranch=$promptColor[gitFlowFeature]
		return
	fi
	# Detached HEAD
	if [[ $promptBranch = 'HEAD' ]]; then
		promptBranch=" ⭠"
		colorBranch=$promptColor[branchDetached]
		return
	fi

	# Default branch
	promptBranch=" "$promptBranch
	colorBranch=$promptColor[branchDefault]
}
# }}}
# updatePushIndicator() {{{
function updatePushIndicator() {
	if [[ $versionSystem = 'git' ]]; then
		updatePushIndicatorGit
		return
	fi
	# No indicator
	promptPushIndicator=''
	colorPushIndicator=''
}
# }}}
# updatePushIndicatorGit() {{{
function updatePushIndicatorGit() {
	# Stop if not a git repo
	if [[ $versionSystem != 'git' ]]; then
		return
	fi

	# We check for the sentence telling us that we are ahead of the origin
	local rawGitStatus
	rawGitStatus=$(git status)

	if [[ $rawGitStatus =~ 'Your branch is ahead of' ]]; then
		promptPushIndicator='⇪ '
		return
	fi

	promptPushIndicator=''
}
# }}}
# updateRebaseIndicator() {{{
function updateRebaseIndicator() {
	if [[ $versionSystem = 'git' ]]; then
		updateRebaseIndicatorGit
		return
	fi
	# No indicator
	promptRebaseIndicator=''
	colorRebaseIndicator=''
}
# }}}
# updateRebaseIndicatorGit() {{{
function updateRebaseIndicatorGit() {
	# Stop if not a git repo
	if [[ $versionSystem != 'git' ]]; then
		return
	fi

	# We check for the file telling us we are in the middle of a rebase
  local repoRoot=$(getRepoRoot)
  local rebaseFile="${repoRoot}/.git/rebase-apply/rebasing"
  if [[ -r $rebaseFile ]]; then
		promptRebaseIndicator='⚶ '
		return
  fi
	promptRebaseIndicator=''
}
# }}}

# Hooks
# chpwd() {{{
# Note: This is automatically called by the prompt whenever we change
# directories
function chpwd() {
	# We update the current version system used
	previousVersionSystem=$versionSystem
	versionSystem=$(get-version-system)

	# We update the current repo root
	previousRepoRoot=$repoRoot
	repoRoot=$(getRepoRoot)

	# Changing path
	promptPath=$(getPromptPath)
	# Changing path color
	colorPath=$(getPromptPathColor)

	# Update aliases
	chpwd_updateAliases
	# Update prompt
	chpwd_updateHash
	chpwd_updateTag
	chpwd_updateSubmodule
	chpwd_updateBranch
	chpwd_updatePushIndicator
	chpwd_updateRebaseIndicator

	# Window title
	print -Pn "\e]2;%n@%m:%~/\a"
}
# }}}
# chpwd_updateAliases() {{{
# When entering a version system, we load the aliases for this system
function chpwd_updateAliases() {
# Staying in same system
if [[ $previousVersionSystem = $versionSystem ]]; then
	return
fi
# Changing system, changing aliases
updateAliases
}
# }}}
# chpwd_updateHash() {{{
function chpwd_updateHash() {
	# Update hash when moving in or out of a repo
	if [[ $repoRoot != $previousRepoRoot ]]; then
		updateHash
	fi
}
# }}}
# chpwd_updateTag() {{{
function chpwd_updateTag() {
	# Update tag when moving in or out of a repo
	if [[ $repoRoot != $previousRepoRoot ]]; then
		updateTag
	fi
}
# }}}
# chpwd_updateSubmodule() {{{
function chpwd_updateSubmodule() {
	# Update submodule when changing version system root.
	# Note : This includes moving from a submodule to another vcs, or no vcs at
	# all.
	if [[ $repoRoot != $previousRepoRoot ]]; then
		updateSubmodule
	fi
}
# }}}
# chpwd_updateBranch() {{{
function chpwd_updateBranch() {
	# Update branch when moving in or out of a repo
	if [[ $repoRoot != $previousRepoRoot ]]; then
		updateBranch
	fi
}
# }}}
# chpwd_updatePushIndicator() {{{
function chpwd_updatePushIndicator() {
# Update push indicator when moving in or out of a repo
if [[ $repoRoot != $previousRepoRoot ]]; then
	updatePushIndicator
fi
}
# }}}
# chpwd_updateRebaseIndicator() {{{
function chpwd_updateRebaseIndicator() {
# Update rebase indicator when moving in or out of a repo
if [[ $repoRoot != $previousRepoRoot ]]; then
	updateRebaseIndicator
fi
}
# }}}
# preexec() {{{
# Note: Is called just before executing a command
function preexec() {
	# We saved the command so we can check it in precmd()
	setPreviousCommand $1
}
# }}}
# precmd() {{{
# Note: Is called right before displaying a new prompt line
function precmd() {
	precmd_updateVersionSystem
	precmd_updateHash
	precmd_updateTag
	precmd_updateBranch
	precmd_updatePushIndicator
	precmd_updateRebaseIndicator
}
# }}}
# precmd_updateVersionSystem() {{{
# Updates the versionSystem when creating a new repo
function precmd_updateVersionSystem() {
	if [[ $previousCommand[1] =~ '^(git|hg)$' && $previousCommand =~ 'init' ]]; then
		# Change the current version system
		previousVersionSystem=$versionSystem
		versionSystem=$previousCommand[1]
		# Update the display
		updateAliases
		updateTag
		updateBranch
	fi
}
# }}}
# precmd_updateHash() {{{
# Updates the hash if the previous command changes the repo status
function precmd_updateHash() {
	local updateHash=0
	
	# Previous command created or removed a file in repo
	if [[ $versionSystem != '' 
		&& $previousCommand[1] =~ '^(better-rmdir|cp|ln|mkdir|mv|rename|rm|rmdir|touch|trash-put|vim)$' ]]; then
		updateHash=1
	fi
	# Git commands
	if [[ $previousCommand[1] = 'git' 
		&& $previousCommand[2] =~ '(add|checkout|clean|clone|commit|create-file|init|merge|mv|rebase|reset|rm|submodule|stash|status|tabula-rasa)' ]]; then
		updateHash=1
	fi
	# Hg command
	if [[ $previousCommand[1] = 'hg' 
		&& $previousCommand[2] =~ '(add|amend|clean|commit|commit-with-diff|create-file|forget|init|mv|purge|revert|rm|status|tabula-rasa|update)' ]]; then
		updateHash=1
	fi

	if [[ $updateHash = 1 ]]; then
		updateHash
	fi
}
# }}}
# precmd_updateTag() {{{
function precmd_updateTag() {
	# Git commands
	if [[ $previousCommand[1] = 'git' 
		&& $previousCommand[2] =~ '(checkout|branch|status|tag)' ]]; then
		updateTag
	fi
}
# }}}
# precmd_updateBranch() {{{
function precmd_updateBranch() {
	# Git commands
	if [[ $previousCommand[1] = 'git' 
		&& $previousCommand[2] =~ '(branch|checkout|commit|current-branch|flow|rebase|status|tag)' ]]; then
		updateBranch
	fi
}
# }}}
# precmd_updatePushIndicator() {{{
function precmd_updatePushIndicator() {
# Git commands
if [[ $previousCommand[1] = 'git' 
	&& $previousCommand[2] =~ '(branch|checkout|commit|commit-all|flow|merge|push|import-feature|init|rollback|status)' ]]; then
	updatePushIndicator
fi
}
# }}}
# precmd_updateRebaseIndicator() {{{
function precmd_updateRebaseIndicator() {
# Git commands
if [[ $previousCommand[1] = 'git' 
	&& $previousCommand[2] =~ '(checkout|rebase|status)' ]]; then
	updateRebaseIndicator
fi
}
# }}}

# Init
# Global variables {{{
export previousVersionSystem='__default__'
export versionSystem=''
export previousRepoRoot='__default__'
export repoRoot=''
export previousCommand

export colorUser=$promptColor[username]
if [[ $UID = 0 ]]; then
	colorUser=$promptColor[root]
fi
export colorHostname=$promptColor[hostname]
export colorPath="$(getPromptPathColor $PWD)"
export colorHash=''
export colorTag=$promptColor[tag]
export colorSubmodule=$promptColor[submodule]
export colorRebase=$promptColor[rebase]
export colorBranch=$promptColor[branchDefault]
export colorDebug=$promptColor[debug]
 
export promptPath="$(getPromptPath $PWD)"
export hashSymbol='%#'
export promptTag=''
export promptSubmodule=''
export promptBranch=''
export promptPushIndicator=''
export promptDebug=''
# }}}
# Initial prompt {{{
# Note: when PROMPT_SUBST is on, updating any value used in PROMPT updates the
# whole prompt
setopt PROMPT_SUBST
# Left and right prompts
PROMPT='$FG[$colorUser]%n$FX[reset]@\
$FG[$colorHostname]%m$FX[reset]:\
$FG[$colorPath]$promptPath$FX[reset] \
$FG[$colorHash]$hashSymbol$FX[reset] \
$FG[$colorDebug]$promptDebug$FX[reset]'
RPROMPT='$FG[$colorTag]$promptTag$FX[reset]\
$FG[$colorSubmodule]$promptSubmodule$FX[reset]\
$FG[$colorRebase]$promptRebaseIndicator$FX[reset]\
$FG[$colorBranch]$promptPushIndicator$promptBranch$FX[reset]'
# }}}

