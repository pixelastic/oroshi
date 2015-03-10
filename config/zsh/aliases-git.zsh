# aliases-git.zsh
# Aliases follow a simple pattern of {Object}{Verb}{Argument}.
# Original idea taken from
# http://floatboth.com/where-i-set-up-my-git-and-hg-aliases-like-a-boss

# [b]ranches {{{
alias vb?='git branch-exists'
alias vbR='git branch -D'
alias vbRr='git branch-remove-remote'
alias vbb='git current-branch'
alias vbc='git checkout -b'
alias vbl='git branch-list'
alias vbla='git branch-list --all'
alias vbm='git rebase'
alias vbmi='git rebase -i'
alias vbmd='vbm develop'
alias vbmm='vbm master'
alias vbmv='git branch -m'
alias vbu='git branch-update'
alias vbru='git remote update && git remote prune origin'
alias vbs='git checkout'
alias vbsd='git checkout develop'
alias vbsm=' git checkout master'
# }}}
# [c]ommits {{{
alias vcR='git commit-remove'
alias vca='git commit-all'
alias vcc='git commit -v'
alias vcd='git diff-last --'
alias vce='git amend'
alias vcl+='git peek --stat'
alias vcl='git peek'
alias vcla='git peek -p'
alias vcp='git prev'
alias vcri='git rebase -i'
alias vcz='git commit-cancel'
function vcf() {
  git log --oneline -i --grep="$1"
}
# }}}
# [f]iles {{{
alias vfR='git rm -r'
alias vfa='git add --all'
alias vfaa='git add --all :/'
alias vfc='git conflicts'
alias vfd='git diff -w --color-words'
alias vfds='git diff-staged --'
alias vfm='git mv'
alias vfr='git checkout --'
alias vfrez='git resurrect'
alias vfu='git unstage'
alias vfua='git reset'
alias vffj='git fix-jshint'
alias vffc='git fix-conflicts'
# }}}
# [re]base {{{
alias vrea='git rebase --abort'
alias vres='git rebase --skip'
alias vrec='git rebase --continue'
# }}}
# [r]emote {{{
alias vr?='git remote-exists'
alias vrR='git remote rm'
alias vrc='git remote-create'
alias vrdw='git download'
alias vrl='git remote -v'
alias vrpl='git remote-pull'
alias vrplu='git remote-pull upstream develop'
alias vrps='git remote-push'
alias vrpsa='git remote-push --all'
alias vrpsh='git push heroku $(git current-branch)'
alias vrr='git remote show origin -n'
# }}}
# [t]ags {{{
alias vtR='git tag -d'
alias vtRr='git-tag-remove-remote'
alias vtc='git tag'
alias vtl='git tag-list'
alias vtlr='git tag-list-remote'
alias vtu='git fetch --tags'
alias vts='git checkout'
alias vtt='git current-tag'
# }}}
# [s]tashes {{{
alias vstR='git stash drop'
alias vstRa='git stash clear'
alias vsta='git stash apply'
alias vst='git stash -u'
alias vstl='git stash list'
# }}}
# [s]ub-[m]odules {{{
alias vsmi='git submodule init'
alias vsmc='git submodule-create'
alias vsmu='git submodule update'
alias vsmdl='git submodule-download'
# }}}
# [m]erge {{{
alias vmt="git mergetool"
# }}}
# working [d]irectory {{{
alias vde='vim $(git root)/.git/config'
alias vdR='git tabula-rasa'
alias vdc='git-directory-create'
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
