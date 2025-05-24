" ZSH

" Use markers for folding
setlocal foldmethod=marker
" ## creates a ${} variable
inoremap <buffer> ## ${}<Left>

" Fixing


" We trick ALE into pretending to use shfmt, but actually using our custom
" zshfix script for fixing zsh. See zshfix for details
let b:ale_fixers = ['shfmt']
let b:ale_sh_shfmt_executable = '/home/tim/.oroshi/scripts/bin/zsh/zshfix-ale'

" Linting
" We trick ALE into pretending to use shellcheck, but actually using our custom
" zshlint script for lintingg zsh. See zshlint for details
let b:ale_linters = ['shellcheck']
let b:ale_sh_shellcheck_executable = '/home/tim/.oroshi/scripts/bin/zsh/zshlint-ale'
