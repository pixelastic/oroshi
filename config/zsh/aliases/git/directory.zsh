# working [d]irectory
alias vdcl='git tabula-rasa'
alias vdc='git-directory-create'
alias vdca='git-directory-create-all'
alias vde='nvim $(git-directory-root)/.git/config'
alias vdl='echo "Use vfl instead" && git-file-list' # My muscle memory is here
alias vdo='git-github-open'
alias vdos='git-github-open-settings'
alias vdrd='vdr && cd ./docs'
alias vdrr='vd? && cd "$(git-directory-root -f)"'
alias vdr='vd? && cd "$(git-directory-root)"'
alias vd?='git-directory-is-repository'
