# Styling {{{
function completion-header() {
  local colorBackground=$COLORS[$1]
  local colorForeground=${COLORS[${2:-black}]}
  local content=${3:-%d}
  echo "%K{${colorBackground}}%F{${colorForeground}}"\
    "${content}%f%F{${COLORS[terminal]}}"\
    "$ICONS[completion-separator]%f%k"
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
  echo "=(#b)(${pattern})(// *)##=38;5;$COLORS[white]=38;5;${color}=38;5;$COLORS[comment]"

  # Matches suggestions that are alone (when several suggestions share the same
  # description).
  # We don't enable it for the default * matcher as it would overwrite the
  # colors of the files defined with LS_COLORS
  if [[ $pattern != "*" ]]; then
    echo "=${pattern}=38;5;${color}"
  fi
}

function oroshi-completion-styling() {
  colors-load-definitions
  icons-load-definitions
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
  local listColorsDefault=()
  listColorsDefault+=("${(f)$(♣ "*" $COLORS[white])}")
  listColorsDefault+=(${completion_LS_COLORS})

  # Color flags
  local listColorsFlag=()
  listColorsFlag+=("${(f)$(♣ "*" $COLORS[flag])}")
  listColorsFlag+=($listColorsDefault)

  # Git {{{
  # Color git branches
  local listColorsGitBranch=()
  listColorsGitBranch+=("${(f)$(♣ "master*" $COLORS[git-branch-master])}")
  listColorsGitBranch+=("${(f)$(♣ "main*" $COLORS[git-branch-main])}")
  listColorsGitBranch+=("${(f)$(♣ "develop*" $COLORS[git-branch-develop])}")
  listColorsGitBranch+=("${(f)$(♣ "dependabot*" $COLORS[git-branch-dependabot])}")
  listColorsGitBranch+=("${(f)$(♣ "*" $COLORS[git-branch])}")
  listColorsGitBranch+=($listColorsDefault)

  # Color git tags
  local listColorsGitTag=()
  listColorsGitTag+=("${(f)$(♣ "*" $COLORS[git-tag])}")
  listColorsGitTag+=($listColorsDefault)

  # Color git remotes
  local listColorsGitRemote=()
  listColorsGitRemote+=("${(f)$(♣ "*" $COLORS[git-remote])}")
  listColorsGitRemote+=($listColorsDefault)

  # Color git submodules
  local listColorsGitSubmodule=()
  listColorsGitSubmodule+=("${(f)$(♣ "*" $COLORS[git-submodule])}")
  listColorsGitSubmodule+=($listColorsDefault)
  # }}}

  # SSH {{{
  # Color remote ssh
  local listColorsKnownHost=()
  listColorsKnownHost+=("${(f)$(♣ "pixelastic*" $COLORS[host-pixelastic])}")
  listColorsKnownHost+=("${(f)$(♣ "github*" $COLORS[host-github])}")
  listColorsKnownHost+=($listColorsDefault)
  # }}}

  # Docker {{{
  # Remote images
  local listColorsDockerImageRemote=()
  listColorsDockerImageRemote+=("${(f)$(♣ "*" $COLORS[docker-image-remote])}")
  listColorsDockerImageRemote+=($listColorsDefault)

  # Local images
  # Note: I still need to find a way to color hashes differently than image
  # names
  local listColorsDockerImage=()
  # listColorsDockerImage+=("${(f)$(♣ "*" $COLORS[docker-image-orphan])}")
  listColorsDockerImage+=("${(f)$(♣ "ghcr.io/*" $COLORS[docker-image-github])}")
  listColorsDockerImage+=("${(f)$(♣ "oroshi:*" $COLORS[docker-image-oroshi])}")
  listColorsDockerImage+=("${(f)$(♣ "[a-z]*" $COLORS[docker-image])}")
  listColorsDockerImage+=($listColorsDefault)

  # Containers
  local listColorsDockerContainer=()
  listColorsDockerContainer+=("${(f)$(♣ "[a-z]*" $COLORS[docker-container])}")
  listColorsDockerContainer+=($listColorsDefault)
  # }}}

  # Yarn {{{
  # Locally linked modules
  local listColorsYarnLinkLocal=()
  listColorsYarnLinkLocal+=("${(f)$(♣ "*" $COLORS[yarn-link-external])}")
  listColorsYarnLinkLocal+=($listColorsDefault)

  # Local dependencies
  local listColorsYarnDependency=()
  listColorsYarnDependency+=("${(f)$(♣ "*" $COLORS[yarn-package])}")
  listColorsYarnDependency+=($listColorsDefault)
  # }}}


  # Note: Disabled because it seems to prevent coloring filetypes and other
  # styling
  # In case of ambiguity, coloring the first letter to type to fix the ambiguity
  # zstyle ':completion:*' show-ambiguity "1;38;5;$COLORS[green]"


  # Default
  zstyle ':completion:*:descriptions' format "$(completion-header header black)"
  zstyle ':completion:*:complete:*:*:*' list-colors $listColorsDefault

  # Files
  local format="$(completion-header file white " $ICONS[completion-file] Files")"
  zstyle ':completion:*:globbed-files' format "$format"

  # Directories
  format="$(completion-header directory white " $ICONS[completion-folder] Directories ")"
  zstyle ':completion:*:local-directories' format "$format"
  zstyle ':completion:*:directories' format "$format"

  # Commands
  format="$(completion-header function black " $ICONS[completion-commands] Commands")"
  zstyle ':completion:*:commands' format "$format"
  format="$(completion-header function black " $ICONS[completion-aliases] Aliases")"
  zstyle ':completion:*:aliases' format "$format"
  zstyle ':completion:*:functions' format "$(completion-header function black ' {} Functions ')"
  format="$(completion-header function black " $ICONS[completion-zsh-builtins] Zsh Builtins")"
  zstyle ':completion:*:builtins' format "$format"

  # Flags
  zstyle ':completion:*:options' format "$(completion-header flag white ' -- Flags ')"
  zstyle ':completion:*:complete:*:*:options' list-colors $listColorsFlag

  # Variables
  zstyle ':completion:*:parameters' format "$(completion-header variable white ' $ Variables ')"

  # Git {{{
  # Branches
  zstyle ':completion:*:complete:git-branch-merge:*:*' list-colors $listColorsGitBranch
  zstyle ':completion:*:complete:git-branch-pull:*:*' list-colors $listColorsGitBranch
  zstyle ':completion:*:complete:git-branch-rebase:*:*' list-colors $listColorsGitBranch
  zstyle ':completion:*:complete:git-branch-remove-remote:*:*' list-colors $listColorsGitBranch
  zstyle ':completion:*:complete:git-branch-remove:*:*' list-colors $listColorsGitBranch
  zstyle ':completion:*:complete:git-branch-switch:*:*' list-colors $listColorsGitBranch
  zstyle ':completion:*:complete:git-worktree-switch:*:*' list-colors $listColorsGitBranch
  zstyle ':completion:*:complete:git-worktree-delete:*:*' list-colors $listColorsGitBranch

  # Tags
  zstyle ':completion:*:complete:git-tag-switch:*:*' list-colors $listColorsGitTag
  zstyle ':completion:*:complete:git-tag-remove:*:*' list-colors $listColorsGitTag
  zstyle ':completion:*:complete:git-tag-remove-remote:*:*' list-colors $listColorsGitTag
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
  zstyle ':completion:*:complete:docker-container-image-name:*:*' \
    list-colors $listColorsDockerContainer
  zstyle ':completion:*:complete:docker-container-image-id:*:*' \
    list-colors $listColorsDockerContainer
  zstyle ':completion:*:complete:docker-container-is-running:*:*' \
    list-colors $listColorsDockerContainer
  # }}}

  # Yarn {{{
  # Globally available modules {{{
  zstyle ':completion:*:complete:yarn-link:*:*' list-colors $listColorsYarnLinkLocal
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

  # Bats tests {{{
  # Note: Using =*=38;5; directly as bats suggestions do not have a description,
  # so ♣ won't work
  local listColorsBatsTest=()
  listColorsBatsTest+=("=*=38;5;${COLORS[function]}")
  listColorsBatsTest+=($listColorsDefault)
  zstyle ':completion:*:complete:bats-test:*:*' list-colors $listColorsBatsTest
  # }}}

  # Running processes
  format="$(completion-header executable black ' $ICONS[completion-process] Running processes ')"
  zstyle ':completion:*:processes-names' format "$format"

  # Original query if no match found
  zstyle ':completion:*:original' format "$(completion-header ui white ' ✘ Original query ')"

  # Fuzzy-find corrections
  zstyle ':completion:*:corrections' format "$(completion-header match black ' ~ Fuzzyfind ')"

  # Error messages
  zstyle ':completion:*:warnings' format "$(completion-header error white ' No match found ')"
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
zstyle ':completion:*:values' format "$(completion-header ui white)"
