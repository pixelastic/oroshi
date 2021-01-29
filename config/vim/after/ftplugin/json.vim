" JSON
" Indentation rules {{{
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab
" }}}
" Folding {{{
setlocal foldmethod=syntax
" }}}
" Cleaning {{{
inoremap <silent> <buffer> <F4> <Esc>:call JSONBeautify()<CR><CR>
nnoremap <silent> <buffer> <F4> :call JSONBeautify()<CR><CR>
function! JSONBeautify() 
  let l:initialLine = line('.')
  execute '%!prettier --parser json'
  execute 'normal '.initialLine.'gg'
  SyntasticCheck()
endfunction
" }}}
" Syntax Highligting {{{
" Use javascript syntax highlighting
augroup ftplugin_json
  autocmd!
  autocmd BufEnter <buffer> setlocal syntax=javascript
augroup END
" }}}

