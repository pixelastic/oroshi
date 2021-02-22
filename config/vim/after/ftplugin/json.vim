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
" If Coc is not enabled, we revert to Syntastic and manual cleaning of file
if !exists('g:coc_enabled')
  let b:syntastic_checkers = ['jsonlint']

  function! JSONBeautify() 
    let l:initialLine = line('.')
    execute '%!prettier --stdin --parser json'
    execute 'normal '.initialLine.'gg'
    SyntasticCheck()
  endfunction

  inoremap <silent> <buffer> <F4> <Esc>:call JSONBeautify()<CR><CR>
  nnoremap <silent> <buffer> <F4> :call JSONBeautify()<CR><CR>
endif
" }}}
" Syntax Highligting {{{
" Use javascript syntax highlighting
augroup ftplugin_json
  autocmd!
  autocmd BufEnter <buffer> setlocal syntax=javascript
augroup END
" }}}

