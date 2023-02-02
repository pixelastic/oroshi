# aliases-git.zsh
# Aliases follow a simple pattern of {Object}{Verb}{Argument}.
# Original idea taken from
# http://floatboth.com/where-i-set-up-my-git-and-hg-aliases-like-a-boss

# [b]ranches {{{
alias vbRr='git-branch-remove-remote'
alias vbR='git-branch-remove'
alias vbc='git-branch-create'
alias vblra='git-branch-list-remote --all'
alias vblro='git-branch-list-remote origin'
alias vblr='git-branch-list-remote'
alias vbl='git-branch-list'
alias vbmi='git-branch-merge-interactive'
alias vbmm='vbm master'
alias vbmv='git-branch-rename'
alias vbm='git-branch-merge'
alias vbpR='git-branch-prune'
alias vbpld='vbpl develop'
alias vbplm='vbpl master'
alias vbpl='git-branch-pull'
alias vbpsF='vbps --force'
alias vbpsfn='vbps --force-with-lease --no-verify'
alias vbpsf='vbps --force-with-lease'
alias vbpsn='vbps --no-verify'
alias vbps='git-branch-push'
alias vbrd='vbr develop'
alias vbrm='vbr master'
alias vbr='git-branch-rebase'
alias vbsd='vbs develop'
alias vbsm='vbs master main'
alias vbsqd='vbsq develop'
alias vbsqm='vbsq master'
alias vbsq='git-branch-squash'
alias vbs='git-branch-switch'
# }}}
# [c]ommits {{{
alias vcRa='git-commit-remove-all'
alias vcR='git-commit-remove'
alias vcaf='git-commit-all -n'
alias vca='git-commit-all'
alias vcc='git-commit-staged'
alias vcd='vca -m "dev(deps): Update dependencies"'
alias vce='git-commit-edit'
alias vcla='git-commit-list --all'
alias vcl+='git-commit-list --more'
alias vcl='git-commit-list'
alias vcri='git rebase -i'
alias vcsqm='git-commit-squash master'
alias vcsq='git-commit-squash'
alias vcv='git show'
alias vcz='git-commit-cancel'
# }}}
# [c]herry [p]ick {{{
alias vcp='git cherry-pick'
# }}}
# working [d]irectory {{{
alias vdcl='git tabula-rasa'
alias vdc='git-directory-create'
alias vde='vim $(git-directory-root)/.git/config'
alias vdl='git status --short'
alias vdo='git-directory-open'
alias vdrd='vdr && cd ./docs'
alias vdrr='vsm? && vdr && cd .. && vdr'
alias vdr='vd? && cd "$(git-directory-root)"'
# }}}
# [f]iles {{{
alias vfR='git rm -r'
alias vfa='git-file-add'
alias vfdc='git diff -w --color-words --cached'
alias vfds='git diff -w --color-words --staged'
alias vfd='git diff -w --color-words'
alias vffc='git-file-fix-conflicts'
alias vfforget='git rm --cached -r'
alias vfh='fzf-git-file-history'
alias vfmv='git mv'
alias vfresurrect='git-file-resurrect'
alias vfrevert='git-file-revert'
alias vfua='git reset'
alias vfu='git-file-unstage'
# }}}
# [g]it [h]ub {{{
alias vghapi='git-github-api'
alias vghrl='git-github-ratelimit'
# }}}
# [i]ssues {{{
alias vic='git-issue-create'
alias vil='git-issue-list'
alias vio='git-issue-open'
# }}}
# [p]ull [r]equests {{{
alias vprl='git-pullrequest-list'
alias vpro='git-pullrequest-open'
# }}}
# [re]base {{{
alias vrea='git rebase --abort'
alias vrec='git rebase --continue'
alias vres='git rebase --skip'
# }}}
# [r]emote {{{
alias vrR='git-remote-remove'
alias vrl='git-remote-list'
alias vrmv='git-remote-rename'
alias vrs='git-remote-switch'
alias vru='git-remote-url'
# }}}
# [t]ags {{{
alias vtRr='git-tag-remove-remote'
alias vtR='git-tag-remove'
alias vtc='git-tag-create'
alias vtlr='git-tag-list-remote'
alias vtl='git-tag-list'
alias vtpl='git fetch --tags'
alias vtps='git-tag-push'
alias vts='git-tag-switch'
# }}}
# [s]tashes {{{
alias vst='git-stash-create'
alias vstR='git stash drop'
alias vstRa='git stash clear'
alias vsta='git-stash-apply'
alias vstl='git stash list'
# }}}
# [s]ub-[m]odules {{{
alias vsmc='git-submodule-create'
alias vsmi='git submodule init'
alias vsmu='git submodule update'
alias vsmR='git-submodule-remove'
# }}}
# [p]rivate [s]ub-[m]odule {{{
alias vsmpu='git commit-submodule ./private'
alias vsmup='git commit-submodule ./private'
# }}}
# [c]oriolis [s]ub-[m]odule {{{
alias vsmuc='git commit-submodule ./scripts/bin/coriolis'
alias vsmcu='git commit-submodule ./scripts/bin/coriolis'
# }}}
# [i]mg [s]ub-[m]odule {{{
alias vsmui='git commit-submodule ./scripts/bin/img'
alias vsmiu='git commit-submodule ./scripts/bin/img'
# }}}
# [pd]f [s]ub-[m]odule {{{
alias vsmupd='git commit-submodule ./scripts/bin/pdf'
alias vsmpdu='git commit-submodule ./scripts/bin/pdf'
alias vsmcpd='git commit-submodule ./scripts/bin/pdf'
alias vsmpdc='git commit-submodule ./scripts/bin/pdf'
# }}}
# [a]nsible [s]ub-[m]odule {{{
alias vsmua='git commit-submodule ./config/ansible/galactica'
alias vsmau='git commit-submodule ./config/ansible/galactica'
alias vsmca='git commit-submodule ./config/ansible/galactica'
alias vsmac='git commit-submodule ./config/ansible/galactica'
# }}}
