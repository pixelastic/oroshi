# aliases-git.zsh
# This file is only loaded when we are in a git repo.
# Aliases follow a simple pattern of {Object}{Verb}{Argument}.
# Original idea taken from
# http://floatboth.com/where-i-set-up-my-git-and-hg-aliases-like-a-boss

# [b]ranches {{{
alias vbR='git branch -D'
alias vbRr='git push origin --delete' # Remove remote branch
alias vbb='git current-branch'
alias vbc='git checkout -b'
alias vbib='git import-branch'
alias vbl='git branch-list'
alias vbla='git branch-list --all'
alias vbm='git merge --no-ff --no-edit'
alias vbmd='vbm develop'
alias vbmm='git rebase master'
alias vbmv='git branch -m'
alias vbrfa='git fetch-all-locally'
alias vbru='git remote update && git remote prune origin'
alias vbs='git checkout'
alias vbsd='cd $(git root) && git checkout develop'
alias vbsm='cd $(git root) && git checkout master'
alias vbud='vbsd && vbm master && vbsm' # Merge master to develop (Update develop)
alias vbuf='git update-feature develop'
alias vbufm='git update-feature master'
alias vbum='vbsm && vbm develop && vbsd' # Merge develop to master (Update master)
# }}}
# [c]ommits {{{
alias vcR='git rollback'
alias vcc='git commit -v'
alias vca='git commit-all'
alias vcd='git diff-last --'
alias vce='git amend'
alias vcl='git peek'
alias vcl+='git peek --stat'
alias vcla='git peek -p'
alias vcp='git prev'
# }}}
# [f]iles {{{
alias vfR='git rm -r'
alias vfa='git add'
alias vfaa='git add --all :/'
alias vfc='git conflicts'
alias vfd='git diff -w'
alias vfds='git diff-staged --'
alias vfm='git mv'
alias vfr='git checkout --'
alias vfrez='git resurrect'
alias vfu='git unstage'
alias vfua='git reset'
alias vffj='git fix-jshint'
alias vffc='git fix-conflicts'
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
# [re]base {{{
alias vrea='git rebase --abort'
alias vres='git rebase --skip'
alias vrec='git rebase --continue'
# }}}
# [r]emote {{{
alias vrR='git remote rm'
alias vra='git remote add'
alias vrdw='git download'
alias vrl='git remote show'
alias vrpl='vdr && git pull --rebase && vsbu && cd -'
alias vrps='git push'
alias vrr='git remote show origin -n'
alias vrpsm='git push origin master'
alias vrpsd='git push origin develop'
alias vrpsh='git push heroku $(git current-branch)'
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
alias vsta='git stash apply'
alias vst='git stash -u'
alias vstl='git stash list'
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
alias vdc='create-repo'
alias vdcl='git clone --recursive'
alias vdcl='git tabula-rasa'
alias vdd='git diff -w'
alias vdds='git diff-staged'
alias vdl='git status-short'
alias vdr='cd $(git root)'
alias vdrr='cd $(git root) && cd .. && cd $(git root)'
alias vdt='get-version-system'
alias vdu='git checkout'
# }}}
