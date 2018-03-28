# aliases-git.zsh
# Aliases follow a simple pattern of {Object}{Verb}{Argument}.
# Original idea taken from
# http://floatboth.com/where-i-set-up-my-git-and-hg-aliases-like-a-boss

# [b]ranches {{{
alias vbM='git-branch-merge'
alias vbRr='git-branch-remove-remote'
alias vbR='git-branch-remove'
alias vbc='git branch-create'
alias vbg?='git branch-gone'
alias vbla='git branch-list -a'
alias vblr='git branch-list-remote'
alias vbl='git branch-list'
alias vbmd='vbm develop'
alias vbmi='git branch-merge-interactive'
alias vbmm='vbm master'
alias vbmv='git-branch-rename'
alias vbm='git-branch-rebase'
alias vbpR='git-branch-prune'
alias vbpld='git branch-pull develop'
alias vbplm='git branch-pull master'
alias vbpl='git branch-pull'
alias vbpsf='git branch-push -f'
alias vbpsh='git branch-push-heroku'
alias vbps='git branch-push'
alias vbsd='git-branch-switch develop'
alias vbsm=' git-branch-switch master'
alias vbsqd='git-branch-squash develop'
alias vbsqm='git-branch-squash master'
alias vbsq='git-branch-squash'
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
alias vcla='git commit-list --all'
alias vcl+='git commit-list --more'
alias vcl='git commit-list'
alias vcri='git rebase -i'
alias vcsq='git commit-squash'
alias vcsqm='git commit-squash master'
alias vcv='git show'
alias vcz='git commit-cancel'
alias vc.='git commit-current'
# }}}
# [c]herry [p]ick {{{
alias vcp='git cherry-pick'
# }}}
# working [d]irectory {{{
alias vdcl='git tabula-rasa'
alias vdc='git-directory-create'
alias vde='vim $(git root)/.git/config'
alias vdl='git status --short'
alias vdrr='vsm? && vdr && cd .. && vdr'
alias vdr='vd? && cd "$(git root)"'
alias vd?='git-is-repository'
# }}}
# [f]iles {{{
alias vfR='git rm -r'
alias vfa='git-file-add'
alias vfd='git diff -w --color-words'
alias vfdc='git diff -w --color-words --cached'
alias vfds='git diff-staged --'
alias vffc='git fix-conflicts'
alias vfmv='git mv'
alias vfforget='git rm --cached -r'
alias vfrevert='git-file-revert'
alias vfresurrect='git resurrect'
alias vfu='git-file-unstage'
alias vfua='git reset'
# }}}
# [g]it {{{
alias vgv='git git-version'
# }}}
# [p]ull [r]equests {{{
alias vprcd='git-pullrequest-create develop'
alias vprcm='git-pullrequest-create master'
alias vprc='git-pullrequest-create'
# }}}
# [re]base {{{
alias vrea='git rebase --abort'
alias vrec='git rebase --continue'
alias vres='git rebase --skip'
# }}}
# [r]emote {{{
alias vrR='git-remote-remove'
alias vrc='git remote-create'
alias vrl='git remote-list'
alias vrmv='git-remote-rename'
alias vrs='git-remote-switch'
alias vru='git-remote-url'
alias vro='git-remote-owner'
alias vr.='git remote-current'
alias vr?='git remote-exists'
# }}}
# [t]ags {{{
alias vtRr='git-tag-remove-remote'
alias vtR='git-tag-remove'
alias vtc='git tag-create'
alias vtlr='git tag-list-remote'
alias vtl='git tag-list'
alias vtpl='git fetch --tags'
alias vtps='git tag-push'
alias vts='git-tag-switch'
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
# [p]rivate [s]ub-[m]odule {{{
alias vcsmp='git commit-private-submodule'
alias vpsmu='git commit-private-submodule'
alias vsmcp='git commit-private-submodule'
alias vsmpu='git commit-private-submodule'
alias vsmup='git commit-private-submodule'
# }}}
# [v]it [s]ub-[m]odule {{{
alias vsmuv='git commit-vit-submodule'
alias vsmvu='git commit-vit-submodule'
alias vsmcv='git commit-vit-submodule'
alias vsmvc='git commit-vit-submodule'
# }}}
# [i]img [s]ub-[m]odule {{{
alias vsmui='git commit-img-submodule'
alias vsmiu='git commit-img-submodule'
alias vsmci='git commit-img-submodule'
alias vsmic='git commit-img-submodule'
# }}}
# [pd]it [s]ub-[m]odule {{{
alias vsmupd='git commit-pdf-submodule'
alias vsmpdu='git commit-pdf-submodule'
alias vsmcpd='git commit-pdf-submodule'
alias vsmpdc='git commit-pdf-submodule'
# }}}
