# aliases-git.zsh
# Aliases follow a simple pattern of {Object}{Verb}{Argument}.
# Original idea taken from
# http://floatboth.com/where-i-set-up-my-git-and-hg-aliases-like-a-boss

# [b]ranches {{{
alias vbRr='git-branch-remove-remote'
alias vbR='git-branch-remove'
alias vbc='git branch-create'
alias vbg?='git branch-gone'
alias vbl='git branch-list'
alias vblr='git branch-list-remote'
alias vblro='git branch-list-remote origin'
alias vblra='git branch-list-remote --all'
alias vbl='git branch-list'
alias vbmi='git branch-merge-interactive'
alias vbmm='vbm master'
alias vbmv='git-branch-rename'
alias vbm='git-branch-merge'
alias vbpR='git-branch-prune'
alias vbpld='vbpl develop'
alias vbplm='vbpl master'
alias vbpl='git branch-pull'
alias vbpsF='vbps --force'
alias vbpsfn='vbps --force-with-lease --no-verify'
alias vbpsf='vbps --force-with-lease'
alias vbpsh='git branch-push-heroku'
alias vbpsn='vbps --no-verify'
alias vbps='git branch-push'
alias vbrd='vbr develop'
alias vbrm='vbr master'
alias vbr='git-branch-rebase'
alias vbsd='vbs develop'
alias vbsm='vbs master main'
alias vbsqd='vbsq develop'
alias vbsqm='vbsq master'
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
alias vcaf='git commit-all -n'
alias vca='git commit-all'
alias vcc='git commit-staged'
alias vcd='vca -m "dev(deps): Update dependencies"'
alias vce='git commit-edit'
alias vcf='git commit-search'
alias vcla='git commit-list --all'
alias vcl+='git commit-list --more'
alias vcl='git commit-list'
alias vcri='git rebase -i'
alias vcsqm='git commit-squash master'
alias vcsq='git commit-squash'
alias vcv='git show'
alias vcz='git commit-cancel'
alias vc.='git commit-current'
alias vc?='git commit-exists'
# }}}
# [c]herry [p]ick {{{
alias vcp='git cherry-pick'
# }}}
# working [d]irectory {{{
alias vdcl='git tabula-rasa'
alias vdc='git-directory-create'
alias vde='vim $(git root)/.git/config'
alias vdl='git status --short'
alias vdo='git directory-open'
alias vdrd='vdr && cd ./docs'
alias vdrr='vsm? && vdr && cd .. && vdr'
alias vdr='vd? && cd "$(git root)"'
alias vdu='git directory-url'
alias vd?='git-is-repository'
# }}}
# [f]iles {{{
alias vfR='git rm -r'
alias vfa='git-file-add'
alias vfd='git diff -w --color-words'
alias vfdc='git diff -w --color-words --cached'
alias vfds='git diff -w --color-words --staged'
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
# [g]it [h]ub {{{
alias vghapi='git github-api'
alias vghapi='git github-rate-limit'
# }}}
# [i]ssues {{{
alias vic='git issue-create'
alias vil='git issue-list'
alias vio='git issue-open'
alias vi#='git issue-count'
# }}}
# [p]ull [r]equests {{{
alias vpr#='git pr-count'
alias vprl='git pr-list'
alias vpro='git pr-open'
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
# [g]ithub pages {{{
alias vgi='github-issues'
alias vgp='github-pull-requests'
alias vgr='github-repo'
alias vgu='github-url'
# }}}
# [s]ub-[m]odules {{{
alias vsmc='git submodule-create'
alias vsmi='git submodule init'
alias vsmu='git submodule update'
alias vsmR='git-submodule-remove'
alias vsm?='git-is-submodule'
# }}}
# [p]rivate [s]ub-[m]odule {{{
alias vsmpu='git commit-private-submodule'
alias vsmup='git commit-private-submodule'
# }}}
# [c]oriolis [s]ub-[m]odule {{{
alias vsmuc='git commit-coriolis-submodule'
alias vsmcu='git commit-coriolis-submodule'
# }}}
# [v]it [s]ub-[m]odule {{{
alias vsmuv='git commit-vit-submodule'
alias vsmvu='git commit-vit-submodule'
# }}}
# [i]img [s]ub-[m]odule {{{
alias vsmui='git commit-img-submodule'
alias vsmiu='git commit-img-submodule'
# }}}
# [pd]it [s]ub-[m]odule {{{
alias vsmupd='git commit-pdf-submodule'
alias vsmpdu='git commit-pdf-submodule'
alias vsmcpd='git commit-pdf-submodule'
alias vsmpdc='git commit-pdf-submodule'
# }}}
# [a]nsible [s]ub-[m]odule {{{
alias vsmua='git commit-ansible-submodule'
alias vsmau='git commit-ansible-submodule'
alias vsmca='git commit-ansible-submodule'
alias vsmac='git commit-ansible-submodule'
# }}}
