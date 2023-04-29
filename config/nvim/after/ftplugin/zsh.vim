" ZSH
" Use markers for folding
setlocal foldmethod=marker
" ## creates a ${} variable
inoremap <buffer> ## ${}<Left>

" Linting
" We trick ALE into using shellcheck for zsh, even if it is not supported. It's
" actually using zshlint, a wrapper, that pretends to be checking bash, but
" ignore all irrelevant errors
let b:ale_sh_shellcheck_executable = "/home/tim/.oroshi/scripts/bin/zshlint"
let b:ale_sh_shellcheck_dialect = "zshlint"
