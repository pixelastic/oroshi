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
alias vbm='git merge --no-ff --no-edit'
alias vbmv='git branch -m'
alias vbRr='git push origin --delete' # Remove remote branch
alias vbs='git checkout'
alias vbsm='cd $(git root) && git checkout master && updatePromptGit'
alias vbsd='cd $(git root) && git checkout develop && updatePromptGit'
alias vbum='vbsm && vbm develop && vbsd && updatePromptGit' # Merge develop to master (Update master)
alias vbuf='git update-feature develop'
alias vbufm='git update-feature master'
# }}}
# [c]ommits {{{
alias vcR='git rollback'
alias vcc='git commit -v'
alias vcca='git commit-all'
alias vcd='git diff-last --'
alias vce='git amend'
alias vcl='git peek'
alias vcla='git peek -p'
alias vcp='git prev'
# }}}
# [f]iles {{{
alias vfR='git rm -r'
alias vfa='git add'
alias vfaa='git add --all'
alias vfc='git create-file'
alias vfd='git diff -w'
alias vfds='git diff-staged --'
alias vfm='git mv'
alias vfr='git checkout --'
alias vfrez='git resurrect'
alias vfu='git unstage'
alias vfua='git reset'
# }}}
# [f]low {{{
alias vfi='git flow init -d'

alias vfff='git flow feature finish'
alias vffpb='git flow feature publish'
alias vffpl='git flow feature pull'
alias vffs='git flow feature start'

alias vfbf='git flow-bugfix finish'
alias vfbpb='git flow-bugfix publish'
alias vfbpl='git flow-bugfix pull'
alias vfbs='git flow-bugfix start'

alias vfhf='git flow hotfix finish'
alias vfhpb='git flow hotfix publish'
alias vfhpl='git flow hotfix pull'
alias vfhs='git flow hotfix start'

alias vfrf='git flow release finish'
alias vfrpb='git flow release publish'
alias vfrpl='git flow release pull'
alias vfrs='git flow release start'
# }}}
# [r]emote {{{
alias vrR='git remote rm'
alias vra='git remote add'
alias vrdw='git download'
alias vrl='git remote show'
alias vrpl='vdr && git pull --no-edit && vsbu && cd -'
alias vrps='git push'
alias vrr='git remote show origin -n'
alias vrpsm='git push origin master'
alias vrpsd='git push origin develop'
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
alias vsbd='git submodule-download'
# }}}
# [m]erge {{{
alias vmt="git mergetool"
# }}}
# working [d]irectory {{{
alias vdR='git tabula-rasa'
alias vdd='git diff -w'
alias vdds='git diff-staged'
alias vdl='git status-short'
alias vdr='cd $(git root)'
alias vdrr='cd $(git root) && cd .. && cd $(git root)'
alias vdu='git checkout'
# }}}
