# prompt.zsh
# This file is responsible for handling what to display in the prompt and will
# keep an inner state of the last command and current version control system

autoload -U promptinit
promptinit

# Array functions
# arrayRemoveIndex() {{{
# Remove the content of an array at the specified index
# arg: String, name of the array
# arg: Int, index to remove
function arrayRemoveIndex() {
	# Note: We create a local copy of the array, work on it, and then update
	# the global array
	local arrayName=$1
	local localArray
	eval "localArray=(\$$arrayName)"
	local index=$2
	local length=${#localArray}

	# Create a new array excluding the specified index
	localArray=(
		"${(@)localArray[1,$index-1]}" 
		"${(@)localArray[$index+1,$length]}"
	)

	# Update the global array
	eval "${arrayName}=($localArray)"
}
# }}}
# arrayConcatenate() {{{
# Concatenate two arrays to create a new one
# arg: String, Name of the final array
# arg: String, Name of the first array
# arg: String, Name of the final array
function arrayConcatenate() {
	local finalArrayName=$1
	local arrayName1=$2
	local arrayName2=$3
	local array1
	local array2

	eval "array1=(\$$arrayName1)"
	eval "array2=(\$$arrayName2)"

	# Concatenate the two arrays
	local localFinalArray
	localFinalArray=("${(@)array1}" "${(@)array2}")

	# Update the global array
	eval "${finalArrayName}=(\$localFinalArray)"
}
# }}}
# arrayFromString() {{{
# Convert a specified string to an array, with a specified separator
# arg: String, Name of the final array
# arg: String, Name of the input string
# arg: String, Separator character. Default to space
function arrayFromString() {
	local arrayName=$1
	local stringName=$2
	eval "local localString=\$$stringName"

	# Separator
	local separator=$3
	if [[ $separator = '' ]]; then
		separator=' ';
	fi
	
	# Split string as array and save it in global array
	eval "${arrayName}=(\${(s:${separator}:)localString})"
}
# }}}

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
# getVersionSystem() {{{
function getVersionSystem() {
	# Check if git
	if [[ $(git --work-tree="$PWD" status 2>/dev/null) != '' ]]; then
		echo 'git'
		return
	fi
	# Check if hg
	if [[ $(hg --cwd "$PWD" root 2>/dev/null) != '' ]]; then
		echo 'hg'
		return
	fi
	# No repo found
	echo ''
	return
}
# }}}
# getRepoRoot() {{{
function getRepoRoot() {
	local repo=''

	# Git
	if [[ $versionSystem = 'git' ]]; then
		repo=$(git rev-parse --show-toplevel 2>/dev/null)
	fi
	# Hg
	if [[ $versionSystem = 'hg' ]]; then
		repo=$(hg --cwd "$PWD" root 2>/dev/null)
	fi
	echo $repo
}
# }}}
# getPromptPath() {{{
# Returns a path that can be displayed in the prompt. Will only keep the first
# dir in the path as well as the last two, and fill with dots in the middle
function getPromptPath() {
	local promptPath=$PWD
	local splitPath
	arrayFromString 'splitPath' 'PWD' '/'

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
function setPreviousCommand() {
	local argCommand=$1
	local	splitCommand
	arrayFromString 'splitCommand' 'argCommand' ' '

	# We expand aliases
	local commandAlias="$(expandCommandAlias $splitCommand[1])"
	if [[ $commandAlias != $splitCommand[1] ]]; then
		local splitCommandAlias
		arrayFromString 'splitCommandAlias' 'commandAlias' ' '
		arrayRemoveIndex 'splitCommand' 1
		arrayConcatenate 'splitCommand' 'splitCommandAlias' 'splitCommand'
	fi

	# We expand hg/git aliases
	local versionSystemAlias=''
	if [[ $splitCommand[1] = 'git' ]]; then
		versionSystemAlias="$(expandGitAlias $splitCommand[2])"
	fi
	if [[ $splitCommand[1] = 'hg' ]]; then
		versionSystemAlias="$(expandHgAlias $splitCommand[2])"
	fi
	if [[ $versionSystemAlias != '' ]]; then
		# We prefix the alias with the initial command
		versionSystemAlias=$splitCommand[1]" "$versionSystemAlias

		# Split the alias in an array
		local splitVersionSystemAlias
		arrayFromString 'splitVersionSystemAlias' 'versionSystemAlias' ' '

		# Remove the initial version command from the start of the command array
		arrayRemoveIndex 'splitCommand' 1
		arrayRemoveIndex 'splitCommand' 1

		# Prepend the full alias to the command array
		arrayConcatenate 'splitCommand' 'splitVersionSystemAlias' 'splitCommand'
	fi

	# We update the global previousCommand
	previousCommand=($splitCommand)
}
# }}}

# Update display
# updateAliases() {{{
function updateAliases() {
if [[ $versionSystem = '' ]]; then
	source ~/.oroshi/config/zsh/aliases-none.zsh
	return
fi
if [[ $versionSystem = 'git' ]]; then
	source ~/.oroshi/config/zsh/aliases-git.zsh
	return
fi
if [[ $versionSystem = 'hg' ]]; then
	source ~/.oroshi/config/zsh/aliases-hg.zsh
	return
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
	promptTag=$shortTag

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
	promptSubmodule='↯'
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
		promptBranch=" ⭠"
		colorBranch=$promptColor[branchMaster]
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

# Hooks
# chpwd() {{{
# Note: This is automatically called by the prompt whenever we change
# directories
function chpwd() {
	# We update the current version system used
	previousVersionSystem=$versionSystem
	versionSystem=$(getVersionSystem)

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
	# Update submodule when staying in a version system but changing the repo
	# root
	if [[ $versionSystem != '' 
				&& $versionSystem = $previousVersionSystem 
				&& $repoRoot != $previousRepoRoot ]]; then
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
		&& $previousCommand[1] =~ '^(better-rmdir|cp|fasd|mkdir|mv|rm|rmdir|touch|trash|vim)$' ]]; then
		updateHash=1
	fi
	# Git commands
	if [[ $previousCommand[1] = 'git' 
		&& $previousCommand[2] =~ '(add|checkout|clean|commit|create-file|init|mv|reset|rm|stash|status|tabula-rasa)' ]]; then
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
		&& $previousCommand[2] =~ '(checkout|branch|tag)' ]]; then
		updateTag
	fi
}
# }}}
# precmd_updateBranch() {{{
function precmd_updateBranch() {
	# Git commands
	if [[ $previousCommand[1] = 'git' 
		&& $previousCommand[2] =~ '(branch|checkout|commit|current-branch|tag)' ]]; then
		updateBranch
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
export colorBranch=$promptColor[branchDefault]
export colorDebug=$promptColor[debug]
 
export promptPath="$(getPromptPath $PWD)"
export hashSymbol='%#'
export promptTag=''
export promptSubmodule=''
export promptBranch=''
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
$FG[$colorBranch]$promptBranch$FX[reset]'
# }}}

