# working [d]irectory
alias vdca='git-directory-create-all'
alias vdcl='git tabula-rasa'
alias vdc='git-directory-create'
alias vde='nvim $(git-directory-root)/.git/config'
alias vdl='echo "Use vfl instead" && git-file-list' # My muscle memory is here
alias vdos='git-github-open-settings'
alias vdo='git-github-open'
alias vdrd='vdr && cd ./docs'
alias vdrr='vd? && cd "$(git-directory-root -f)"'
alias vdr='vd? && cd "$(git-directory-root)"'
alias vds='git-directory-sync'
alias vd?='git-directory-is-repository'
