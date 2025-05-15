" SCSS
" Misc {{{
" Remove - and _ from delimiters
setlocal iskeyword=@,48-57,192-255
" }}}
" Folding {{{
setlocal foldmethod=syntax
" }}}
" Indentation rules {{{
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab
" }}}
" Keybindings {{{
nnoremap ss viB:sort<CR>
" Using ## (as in ruby) for string interpolation
inoremap <buffer> ## #{$}<Left>
" }}}
