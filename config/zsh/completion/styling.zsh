# Styling {{{
function completion-header() {
  local colorBackground=$1
  local colorForeground=${2:-$COLOR_BLACK}
  local content=${3:-%d}
  echo "%K{$colorBackground}%F{$colorForeground}$content%f%F{$COLOR_ALIAS_TERMINAL}%f%k"
}

# Color specific values in a specific color
function ♣() {
  local pattern="$1"
  local color="$2"
  # The string is split in 4 parts, separated by =
  # The first part is the pattern to match.
  # The second part is the default color
  # The 3rd and 4th parts are the colors for the 1st (value) and 2nd (comment)
  # matching groups of the pattern
  #
  # (#b) is required at the start of a pattern to allow for multiple matching
  # groups.
  # ## is similar to ? in other regexp: allow a match, or nothing
  # The first matching group is whatever is before // and the second is // and
  # the description
  echo "=(#b)(${pattern})(// *)##=38;5;$COLOR_WHITE=38;5;${color}=38;5;$COLOR_ALIAS_COMMENT"

  # Matches suggestions that are alone (when several suggestions share the same
  # description).
  # We don't enable it for the default * matcher as it would overwrite the
  # colors of the files defined with LS_COLORS
  if [[ $pattern != "*" ]]; then
    echo "=${pattern}=38;5;${color}"
  fi
}

function oroshi-completion-styling() {
  setopt EXTENDED_GLOB

  # We'll use the mapping of extensions to color defined in LS_COLORS to
  # colorize the completion. ZSH has an added syntax where if the first part of
  # the definition starts with an "=", then it performs an exact match instead
  # of a glob.
  # So we need to convert our LS_COLORS so every definition that doesn't start
  # with a "*" will have a "=" added.
  local completion_LS_COLORS=${LS_COLORS//(#b):([^*])/:=${match[1]}}
  # We split the long string on :
  completion_LS_COLORS=${(s.:.)completion_LS_COLORS}
  
  # Default coloring
  local listColorsDefault=(\
    # Default color
    "${(f)$(♣ "*" $COLOR_WHITE)}"
    
    # File and directory colors
    ${completion_LS_COLORS}
  )
  # Color flags
  local listColorsFlag=(\
    "${(f)$(♣ "*" $COLOR_ALIAS_FLAG)}" \
    $listColorsDefault \
  )
  # Git {{{
  # Color git branches
  local listColorsGitBranch=(\
    "${(f)$(♣ "master*" $COLOR_ALIAS_GIT_BRANCH_MASTER)}" \
    "${(f)$(♣ "main*" $COLOR_ALIAS_GIT_BRANCH_MAIN)}" \
    "${(f)$(♣ "develop*" $COLOR_ALIAS_GIT_BRANCH_DEVELOP)}" \
    "${(f)$(♣ "dependabot*" $COLOR_ALIAS_GIT_BRANCH_DEPENDABOT)}" \
    "${(f)$(♣ "*" $COLOR_ALIAS_GIT_BRANCH)}" \
    $listColorsDefault \
  )
  # Color git tags
  local listColorsGitTag=(\
    "${(f)$(♣ "*" $COLOR_ALIAS_GIT_TAG)}" \
    $listColorsDefault \
  )
  # Color git remotes
  local listColorsGitRemote=(\
    "${(f)$(♣ "*" $COLOR_ALIAS_GIT_REMOTE)}" \
    $listColorsDefault \
  )
  # Color git submodules
  local listColorsGitSubmodule=(\
    "${(f)$(♣ "*" $COLOR_ALIAS_GIT_SUBMODULE)}" \
    $listColorsDefault \
  )
  # }}}
  # SSH {{{
  # Color remote ssh
  local listColorsKnownHost=(\
      "${(f)$(♣ "pixelastic*" $COLOR_ALIAS_HOST_PIXELASTIC)}" \
      "${(f)$(♣ "github*" $COLOR_ALIAS_HOST_GITHUB)}" \
      $listColorsDefault \
    )
  # }}}
  # Docker {{{
  # Remote images
  local listColorsDockerImageRemote=(\
      "${(f)$(♣ "*" $COLOR_ALIAS_DOCKER_IMAGE_REMOTE)}" \
      $listColorsDefault \
    )
  # Local images
  # Note: I still need to find a way to color hashes differently than image
  # names
  # "${(f)$(♣ "*" $COLOR_ALIAS_DOCKER_IMAGE_ORPHAN)}" \
    local listColorsDockerImage=(\
      "${(f)$(♣ "ghcr.io/*" $COLOR_ALIAS_DOCKER_IMAGE_GITHUB)}" \
      "${(f)$(♣ "oroshi:*" $COLOR_ALIAS_DOCKER_IMAGE_OROSHI)}" \
      "${(f)$(♣ "[a-z]*" $COLOR_ALIAS_DOCKER_IMAGE)}" \
      $listColorsDefault \
    )
  # Containers
  local listColorsDockerContainer=(\
      "${(f)$(♣ "[a-z]*" $COLOR_ALIAS_DOCKER_CONTAINER)}" \
      $listColorsDefault \
    )
  # }}}
  # Yarn {{{
  # Globally available modules
  local listColorsYarnLinkGlobal=(\
      "${(f)$(♣ "*" $COLOR_ALIAS_YARN_LINK_GLOBAL)}" \
      $listColorsDefault \
    )
  # Locally linked modules
  local listColorsYarnLinkLocal=(\
      "${(f)$(♣ "*" $COLOR_ALIAS_YARN_LINK_LOCAL)}" \
      $listColorsDefault \
    )
  # Local dependencies
  local listColorsYarnDependency=(\
      "${(f)$(♣ "*" $COLOR_ALIAS_YARN_PACKAGE)}" \
      $listColorsDefault \
    )
  # }}}


  # Note: Disabled because it seems to prevent coloring filetypes and other
  # styling
  # In case of ambiguity, coloring the first letter to type to fix the ambiguity
  # zstyle ':completion:*' show-ambiguity "1;38;5;$COLOR_GREEN"


  # Default
  zstyle ':completion:*:descriptions' format "$(completion-header $COLOR_ALIAS_HEADER $COLOR_BLACK)"
  zstyle ':completion:*:complete:*:*:*' list-colors $listColorsDefault

  # Files
  zstyle ':completion:*:globbed-files' format "$(completion-header $COLOR_ALIAS_FILE $COLOR_WHITE '  Files ')"

  # Directories
  zstyle ':completion:*:local-directories' format "$(completion-header $COLOR_ALIAS_DIRECTORY $COLOR_WHITE '  Directories ')"
  zstyle ':completion:*:directories' format "$(completion-header $COLOR_ALIAS_DIRECTORY $COLOR_WHITE '  Directories ')"

  # Commands
  zstyle ':completion:*:commands'  format "$(completion-header $COLOR_ALIAS_FUNCTION $COLOR_BLACK '  Commands ')"
  zstyle ':completion:*:aliases'  format "$(completion-header $COLOR_ALIAS_FUNCTION $COLOR_BLACK '  Aliases ')";
  zstyle ':completion:*:functions' format "$(completion-header $COLOR_ALIAS_FUNCTION $COLOR_BLACK ' {} Functions ')"
  zstyle ':completion:*:builtins'  format "$(completion-header $COLOR_ALIAS_FUNCTION $COLOR_BLACK '  Zsh Builtins ')"

  # Flags
  zstyle ':completion:*:options' format "$(completion-header $COLOR_ALIAS_FLAG $COLOR_WHITE ' -- Flags ')"
  zstyle ':completion:*:complete:*:*:options' list-colors $listColorsFlag

  # Variables
  zstyle ':completion:*:parameters' format "$(completion-header $COLOR_ALIAS_VARIABLE $COLOR_WHITE ' $ Variables ')"

  # Git {{{
  # Branches
  zstyle ':completion:*:complete:git-branch-merge:*:*' list-colors $listColorsGitBranch
  zstyle ':completion:*:complete:git-branch-pull:*:*' list-colors $listColorsGitBranch
  zstyle ':completion:*:complete:git-branch-rebase:*:*' list-colors $listColorsGitBranch
  zstyle ':completion:*:complete:git-branch-remove-remote:*:*' list-colors $listColorsGitBranch
  zstyle ':completion:*:complete:git-branch-remove:*:*' list-colors $listColorsGitBranch
  zstyle ':completion:*:complete:git-branch-switch:*:*' list-colors $listColorsGitBranch
  
  # Tags
  zstyle ':completion:*:complete:git-tag-switch:*:*' list-colors $listColorsGitTag
  zstyle ':completion:*:complete:git-tag-remove:*:*' list-colors $listColorsGitTag
  zstyle ':completion:*:complete:git-tag-status:*:*' list-colors $listColorsGitTag

  # Remotes
  zstyle ':completion:*:complete:git-remote-remove:*:*' list-colors $listColorsGitRemote
  zstyle ':completion:*:complete:git-remote-rename:*:*' list-colors $listColorsGitRemote
  zstyle ':completion:*:complete:git-remote-switch:*:*' list-colors $listColorsGitRemote
  
  # Submodules
  zstyle ':completion:*:complete:git-submodule-remove:*:*' list-colors $listColorsGitSubmodule
  # }}}

  # Docker {{{
  # Local images
  zstyle ':completion:*:complete:docker-image-count:*:*' list-colors $listColorsDockerImage
  zstyle ':completion:*:complete:docker-image-id:*:*' list-colors $listColorsDockerImage
  zstyle ':completion:*:complete:docker-image-name:*:*' list-colors $listColorsDockerImage
  zstyle ':completion:*:complete:docker-image-copy:*:*' list-colors $listColorsDockerImage
  zstyle ':completion:*:complete:docker-image-comment:*:*' list-colors $listColorsDockerImage
  zstyle ':completion:*:complete:docker-image-copy-github:*:*' list-colors $listColorsDockerImage
  zstyle ':completion:*:complete:docker-image-exists:*:*' list-colors $listColorsDockerImage
  zstyle ':completion:*:complete:docker-image-list:*:*' list-colors $listColorsDockerImage
  zstyle ':completion:*:complete:docker-image-remove:*:*' list-colors $listColorsDockerImage
  zstyle ':completion:*:complete:docker-image-push:*:*' list-colors $listColorsDockerImage
  zstyle ':completion:*:complete:docker-run:*:*' list-colors $listColorsDockerImage
  zstyle ':completion:*:complete:docker-run-interactive:*:*' list-colors $listColorsDockerImage
  zstyle ':completion:*:complete:docker-container-count:*:*' list-colors $listColorsDockerImage
  # Remote images
  zstyle ':completion:*:complete:docker-image-pull:*:*' list-colors $listColorsDockerImageRemote
  # Containers
  zstyle ':completion:*:complete:docker-container-exists:*:*' list-colors $listColorsDockerContainer
  zstyle ':completion:*:complete:docker-container-remove:*:*' list-colors $listColorsDockerContainer
  zstyle ':completion:*:complete:docker-container-state:*:*' list-colors $listColorsDockerContainer
  zstyle ':completion:*:complete:docker-container-name:*:*' list-colors $listColorsDockerContainer
  zstyle ':completion:*:complete:docker-container-id:*:*' list-colors $listColorsDockerContainer
  zstyle ':completion:*:complete:docker-container-image-name:*:*' list-colors $listColorsDockerContainer
  zstyle ':completion:*:complete:docker-container-image-id:*:*' list-colors $listColorsDockerContainer
  zstyle ':completion:*:complete:docker-container-is-running:*:*' list-colors $listColorsDockerContainer
  # }}}

  # Yarn {{{
  # Globally available modules {{{
  zstyle ':completion:*:complete:yarn-link:*:*' list-colors $listColorsYarnLinkGlobal
  zstyle ':completion:*:complete:yarn-link-remove-global:*:*' list-colors $listColorsYarnLinkGlobal
  # }}}
  # Locally linked modules {{{
  zstyle ':completion:*:complete:yarn-link-remove:*:*' list-colors $listColorsYarnLinkLocal
  # }}}
  # Local dependencies {{{
  zstyle ':completion:*:complete:yarn-update:*:*' list-colors $listColorsYarnDependency
  # }}}
  # }}}

  # SSH Host
  zstyle ':completion:*:complete:ssh:*:*' list-colors $listColorsKnownHost

  # Running processes
  zstyle ':completion:*:processes-names' format "$(completion-header $COLOR_ALIAS_PROCESS $COLOR_BLACK '  Running processes ')"

  # Original query if no match found
  zstyle ':completion:*:original' format "$(completion-header $COLOR_ALIAS_UI $COLOR_WHITE ' ✘ Original query ')"

  # Fuzzy-find corrections
  zstyle ':completion:*:corrections' format "$(completion-header $COLOR_ALIAS_MATCH $COLOR_BLACK ' ~ Fuzzyfind ')"

  # Error messages
  zstyle ':completion:*:warnings' format "$(completion-header $COLOR_ALIAS_ERROR $COLOR_WHITE ' No match found ')"
  # }}}
}
oroshi-completion-styling
unfunction oroshi-completion-styling


# Unknown elements
zstyle ':completion:*:arguments' format "arguments: %d"
zstyle ':completion:*:files' format "files: %d"
zstyle ':completion:*:history-words' format "history-words: %d"
zstyle ':completion:*:host' format "host: %d"
zstyle ':completion:*:manuals' format "manuals: %d"
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:named-directories' format "named-directories: %d"
zstyle ':completion:*:names' format "names: %d"
zstyle ':completion:*:paths' format "paths: %d"
zstyle ':completion:*:path-directories' format "path-directories: %d"
zstyle ':completion:*:suffixes' format "suffixes: %d"
zstyle ':completion:*:urls' format "urls: %d"
# Arbitrary values
zstyle ':completion:*:values' format "$(completion-header $COLOR_ALIAS_UI $COLOR_WHITE)"
