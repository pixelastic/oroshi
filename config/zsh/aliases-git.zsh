# aliases-git.zsh
# Aliases follow a simple pattern of {Object}{Verb}{Argument}.
# Original idea taken from
# http://floatboth.com/where-i-set-up-my-git-and-hg-aliases-like-a-boss

# [b]ranches {{{
alias vb?='git branch-exists'
alias vbR='git branch -D'
alias vbRr='git branch-remove-remote'
alias vbb='git branch-current'
alias vbc='git checkout -b'
alias vbl='git branch-list'
alias vbla='git branch-list --all'
alias vbm='git rebase'
alias vbmd='vbm develop'
alias vbmi='git branch-merge-interactive'
alias vbmm='vbm master'
alias vbmv='git branch -m'
alias vbs='git checkout'
alias vbsd='git checkout develop'
alias vbsm=' git checkout master'
alias vbu='git branch-update'
# }}}
# [c]ommits {{{
alias vcR='git commit-remove'
alias vca='git commit-all'
alias vcc='git commit -v'
alias vce='git amend'
alias vcf='git commit-search'
alias vcl+='git peek --stat'
alias vcl='git peek'
alias vcla='git peek -p'
alias vcri='git rebase -i'
# }}}
# [f]iles {{{
alias vfR='git rm -r'
alias vfa='git add --all'
alias vfd='git diff -w --color-words'
alias vfds='git diff-staged --'
alias vffc='git fix-conflicts'
alias vffj='git fix-jshint'
alias vfmv='git mv'
alias vfr='git checkout --'
alias vfrez='git resurrect'
alias vfu='git unstage'
alias vfua='git reset'
# }}}
# [re]base {{{
alias vrea='git rebase --abort'
alias vrec='git rebase --continue'
alias vres='git rebase --skip'
# }}}
# [r]emote {{{
alias vr?='git remote-exists'
alias vrR='git remote rm'
alias vrc='git remote-create'
alias vrl='git remote -v'
alias vrpl='git remote-pull'
alias vrplu='git remote-pull upstream'
alias vrps='git remote-push'
alias vrpsa='git remote-push --all'
alias vrr='git remote-current'
# }}}
# [t]ags {{{
alias vt?='git tag-exists'
alias vtR='git tag -d'
alias vtRr='git-tag-remove-remote'
alias vtc='git tag'
alias vtl='git tag-list'
alias vtlr='git tag-list-remote'
alias vtpl='git fetch --tags'
alias vtps='git tag-push'
alias vts='git checkout'
alias vtt='git current-tag'
# }}}
# [s]tashes {{{
alias vst='git stash -u'
alias vstR='git stash drop'
alias vstRa='git stash clear'
alias vsta='git stash-apply'
alias vstl='git stash list'
# }}}
# [s]ub-[m]odules {{{
alias vsmc='git submodule-create'
alias vsmi='git submodule init'
alias vsmu='git submodule update'
# }}}
# working [d]irectory {{{
alias vdc='git-directory-create'
alias vdcl='git tabula-rasa'
alias vde='vim $(git root)/.git/config'
alias vdl='git status --short'
alias vdr='cd $(git root)'
alias vdrr='vdr && cd .. && vdr'
# }}}
