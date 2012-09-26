# aliases-git.zsh
# This file is only loaded when we are in a git repo.
# Aliases follow a simple pattern of {Object}{Verb}{Argument}.
# Original idea taken from
# http://floatboth.com/where-i-set-up-my-git-and-hg-aliases-like-a-boss

# [b]ranches {{{
alias vbb='git current-branch'
alias vbc='git checkout -b'
alias vbl='git branch-list'
alias vbm='git branch -m'
alias vbr='git branch -d'
alias vbR='git branch -D'
alias vbrr='git push origin --delete' # Remove remote branch
alias vbs='git checkout'
alias vbsm='git checkout master'
# }}}
# [c]ommits {{{
alias vcc='git commit -v'
alias vcca='git commit-all'
alias vcd='git diff'
alias vce='git amend'
alias vcl='git peek'
alias vcla='git peek -p'
alias vcr='git rollback'
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
# [r]emote {{{
alias vrR='git remote rm'
alias vra='git remote add'
alias vrdw='git download'
alias vrl='git remote show'
alias vrpl='git pull'
alias vrps='git push'
alias vrr='git remote show origin -n'
# }}}
# [t]ags {{{
alias vtc='git tag'
alias vtl='git tag-list'
alias vtr='git tag -d'
alias vts='git checkout'
alias vtt='git current-tag'
# }}}
# [s]tashes {{{
alias vsR='git stash clear'
alias vsc='git stash'
alias vse='git stash apply'
alias vsl='git stash list'
alias vsr='git stash drop'
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
