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
" Linting {{{
let b:syntastic_checkers = ['sass', 'stylelint']

" If stylelint is not present in this repo, we use the global config
call  system('npm-is-local stylelint')
if (v:shell_error)
  let b:syntastic_scss_stylelint_args = '
  \--config ~/.stylelintrc.scss.js 
  \--config-basedir ~/.config/yarn/global'
endif
" }}}
" Cleaning {{{
inoremap <silent> <buffer> <F4> <Esc>:call SCSSBeautify()<CR><CR>
nnoremap <silent> <buffer> <F4> :call SCSSBeautify()<CR><CR>
function! SCSSBeautify() 
  let l:initialLine = line('.')
  execute '%!prettier --stdin --parser scss'
  execute 'normal '.initialLine.'gg'
  SyntasticCheck()
endfunction
" }}}
" Keybindings {{{
nnoremap ss viB:sort<CR>
" Using ## (as in ruby) for string interpolation
inoremap <buffer> ## #{$}<Left>
" }}}
