# aliases-git.zsh
# This file is only loaded when we are in a git repo.
# Aliases follow a simple pattern of {Object}{Verb}{Argument}.
# Original idea taken from
# http://floatboth.com/where-i-set-up-my-git-and-hg-aliases-like-a-boss

# [b]ranches {{{
alias vbR='git branch -D'
alias vbb='git current-branch'
alias vbc='git checkout -b'
alias vbl='git branch-list'
alias vbm='git merge --no-ff'
alias vbmd='git merge --squash develop && git commit -m "BRANCH: Merged `develop`"'
alias vbms='git merge --squash'
alias vbmv='git branch -m'
alias vbrr='git push origin --delete' # Remove remote branch
alias vbs='git checkout'
alias vbsm='git checkout master'
alias vbsd='git checkout develop'
# }}}
# [c]ommits {{{
alias vcc='git commit -v'
alias vcca='git commit-all'
alias vcd='git diff'
alias vce='git amend'
alias vcl='git peek'
alias vcla='git peek -p'
alias vcR='git rollback'
# }}}
# [f]iles {{{
alias vfa='git add'
alias vfaa='git add --all'
alias vfc='git create-file'
alias vfm='git mv'
alias vfr='git checkout --'
alias vfR='git rm -r'
alias vfu='git unstage'
# }}}
# [f]low {{{
alias vfi='git flow init -d'
alias vfff='cd $(git root) && git flow feature finish'
alias vffpb='git flow feature publish'
alias vffpl='git flow feature pull'
alias vffs='git flow feature start'
alias vffl='git flow feature list'
alias vfhf='cd $(git root) && git flow hotfix finish'
alias vfhpb='git flow hotfix publish'
alias vfhpl='git flow hotfix pull'
alias vfhs='git flow hotfix start'
alias vfhl='git flow hotfix list'
alias vfrf='cd $(git root) && git flow release finish'
alias vfrpb='git flow release publish'
alias vfrpl='git flow release pull'
alias vfrs='git flow release start'
alias vfrl='git flow release list'
# }}}
# [r]emote {{{
alias vrR='git remote rm'
alias vrc='git remote add'
alias vrdw='git download'
alias vrl='git remote show'
alias vrpl='git pull'
alias vrps='git push'
alias vrr='git remote show origin -n'
# }}}
# [t]ags {{{
alias vtc='git tag'
alias vtl='git tag-list'
alias vtR='git tag -d'
alias vts='git checkout'
alias vtt='git current-tag'
# }}}
# [s]tashes {{{
alias vsR='git stash drop' # delete one stash
alias vsRa='git stash clear' # delete all stashes
alias vsa='git stash apply'
alias vsc='git stash'
alias vsl='git stash list'
# }}}
# [s]u[b]-modules {{{
alias vbsi='git submodule init'
alias vsba='git submodule add'
alias vsbu='git submodule update'
# }}}
# working [d]irectory {{{
alias vdR='git tabula-rasa'
alias vdd='git diff'
alias vddl='git diff-last'
alias vdl='git status-short'
alias vdr='cd $(git root)'
alias vdrr='cd $(git root) && cd .. && cd $(git root)'
alias vdu='git checkout'
# }}}
