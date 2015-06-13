# aliases-git.zsh
# Aliases follow a simple pattern of {Object}{Verb}{Argument}.
# Original idea taken from
# http://floatboth.com/where-i-set-up-my-git-and-hg-aliases-like-a-boss

# [b]ranches {{{
alias vb?='git branch-exists'
alias vbM='git merge --no-edit'
alias vbR='git branch -D'
alias vbRr='git branch-remove-remote'
alias vbb='git branch-current'
alias vbc='git branch-create'
alias vbl='git branch-list'
alias vblr='git branch-list-remote'
alias vbm='git rebase'
alias vbmd='vbm develop'
alias vbmi='git branch-merge-interactive'
alias vbmm='vbm master'
alias vbmv='git branch -m'
alias vbpl='git branch-pull'
alias vbps='git branch-push'
alias vbs-='git checkout -'
alias vbs='git checkout'
alias vbsd='git checkout develop'
alias vbsm=' git checkout master'
alias vbu='git branch-update'
# }}}
# [c]ommits {{{
alias vcR='git commit-remove'
alias vcRa='git commit-remove-all'
alias vcz='git commit-cancel'
alias vca='git commit-all'
alias vcc='git commit -v'
alias vce='git commit-edit'
alias vcf='git commit-search'
alias vcl+='git peek --stat'
alias vcl='git peek'
alias vcla='git peek -p -D'
alias vcri='git rebase -i'
alias vcv='git show'
# }}}
# [c]herry [p]ick {{{
alias vcp='git cherry-pick'
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
# [g]it {{{
alias vgv='git git-version'
# }}}
# [re]base {{{
alias vrea='git rebase --abort'
alias vrec='git rebase --continue'
alias vres='git rebase --skip'
# }}}
# [r]emote {{{
alias vrR='git remote rm'
alias vrc='git remote-create'
alias vrl='git remote-list'
alias vrmv='git remote rename'
alias vrpl='echo "✘ Use vbpl instead"'
alias vrps='echo "✘ Use vbps instead"'
alias vrr='git remote-current'
alias vrs='git remote-switch'
alias vr?='git remote-exists'
# }}}
# [t]ags {{{
alias vt?='git tag-exists'
alias vt?r='git tag-exists-remote'
alias vtR='git tag -d'
alias vtRr='git tag-remove-remote'
alias vtc='git tag-create'
alias vtl='git tag-list'
alias vtlr='git tag-list-remote'
alias vtpl='git fetch --tags'
alias vtps='git tag-push'
alias vts='git checkout'
alias vtt='git tag-current'
alias vtta='git tag-current-all'
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
alias vsmR='git-submodule-remove'
alias vsm?='git-is-submodule'
# }}}
# working [d]irectory {{{
alias vdc='git-directory-create'
alias vdcl='git tabula-rasa'
alias vde='vim $(git root)/.git/config'
alias vdl='git status --short'
alias vdr='cd $(git root)'
alias vdrr='vdr && cd .. && vdr'
# }}}
