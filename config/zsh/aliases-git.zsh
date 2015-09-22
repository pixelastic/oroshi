# aliases-git.zsh
# Aliases follow a simple pattern of {Object}{Verb}{Argument}.
# Original idea taken from
# http://floatboth.com/where-i-set-up-my-git-and-hg-aliases-like-a-boss

# [b]ranches {{{
alias vbM='git merge --no-edit'
alias vbRr='git branch-remove-remote'
alias vbR='git branch -D'
alias vbc='git branch-create'
alias vblr='git branch-list-remote'
alias vbl='git branch-list'
alias vbmd='vbm develop'
alias vbmi='git branch-merge-interactive'
alias vbmm='vbm master'
alias vbmv='git branch -m'
alias vbm='git-branch-merge'
alias vbpl='git branch-pull'
alias vbpsh='git branch-push-heroku'
alias vbps='git branch-push'
alias vbsd='git checkout develop'
alias vbsm=' git checkout master'
alias vbs-='git checkout -'
alias vbs='git-branch-switch'
alias vbu='git branch-update'
alias vb.='git branch-current'
alias vb?='git branch-exists'
# }}}
# [c]ommits {{{
alias vcRa='git commit-remove-all'
alias vcR='git commit-remove'
alias vca='git commit-all'
alias vcc='git commit -v'
alias vce='git commit-edit'
alias vcf='git commit-search'
alias vcla='git peek -p -D'
alias vcl+='git peek --stat'
alias vcl='git peek'
alias vcri='git rebase -i'
alias vcupsm='git commit-private-submodule'
alias vcv='git show'
alias vcz='git commit-cancel'
alias vc.='git commit-current'
# }}}
# [c]herry [p]ick {{{
alias vcp='git cherry-pick'
# }}}
# working [d]irectory {{{
alias vdc='git-directory-create'
alias vdcl='git tabula-rasa'
alias vde='vim $(git root)/.git/config'
alias vdl='git status --short'
alias vdr='cd $(git root)'
alias vdrr='vdr && cd .. && vdr'
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
alias vrs='git-remote-switch'
alias vr.='git remote-current'
alias vr?='git remote-exists'
# }}}
# [t]ags {{{
alias vtRr='git tag-remove-remote'
alias vtR='git tag -d'
alias vtc='git tag-create'
alias vtlr='git tag-list-remote'
alias vtl='git tag-list'
alias vtpl='git fetch --tags'
alias vtps='git tag-push'
alias vts='git checkout'
alias vt.a='git tag-current-all'
alias vt.='git tag-current'
alias vt?r='git tag-exists-remote'
alias vt?='git tag-exists'
# }}}
# [s]tashes {{{
alias vst='git stash-create'
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
