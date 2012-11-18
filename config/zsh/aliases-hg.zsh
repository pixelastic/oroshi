# aliases-hg.zsh
# This file is only loaded when we are in a hg repo.
# Aliases follow a simple pattern of {Object}{Verb}{Argument}.
# Original idea taken from
# http://floatboth.com/where-i-set-up-my-git-and-hg-aliases-like-a-boss

# [b]ranches {{{
alias vbc='hg branch'
alias vbl='hg branches'
# }}}
# [c]ommits {{{
alias vcc='hg commit-with-diff'
alias vcca='hg commit-with-diff --addremove'
alias vcd='hg diff'
alias vce='hg amend'
alias vcl='hg peek'
alias vcla='hg history'
alias vcr='hg rollback'
# }}}
# [f]iles {{{
alias vfR='hg rm'
alias vfa='hg add'
alias vfaa='hg add'
alias vfc='hg create-file'
alias vfm='hg mv'
alias vfr='hg revert'
alias vfu='hg forget'
# }}}
# [r]emote {{{
alias vrc='hg clone'
alias vrpl='hg pull'
alias vrps='hg push'
alias vrout='hg outgoing'
alias vrin='hg incoming'
# }}}
# [t]ags {{{
alias vtc='hg tag'
alias vtl='hg tags'
alias vtr='hg tag --remove'
# }}}
# working [d]irectory {{{
alias vdR='hg update --clean'
alias vdd='hg diff'
alias vdl='hg status'
alias vdr='cd $(hg root)'
alias vdra='hg tabula-rasa'
alias vdu='hg update'
# }}}
