" JSON
" Indentation rules {{{
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab
setlocal equalprg=js-beautify\ -f\ -
" }}}
" Cleaning the file {{{
nnoremap <silent> <buffer> <F4> :call JSONBeautify()<CR>
function! JSONBeautify() 
  execute '%!jq -M "."'
endfunction
" }}}
" Folding {{{
setlocal foldmethod=syntax
" }}}
" csslintrc.json {{{
" Note: csslint does not allow us to pass a config file when running it form the
" command line, it only accept arguments.
" But with the number of rules to pass, this makes for very long arguments, so
" we've written a config file in JSON which will get parsed as arguments and
" written in ~/.csslintrc
if expand('%') =~ 'csslintrc.json'
  augroup csslintrc_json_to_rc
    autocmd!
    autocmd BufWritePost <buffer> silent! execute '!~/.oroshi/scripts/deploy/csslint'
  augroup END
endif
" }}}
" Use javascript syntax highlighting
augroup ftplugin_json
  autocmd!
  autocmd BufEnter <buffer> setlocal syntax=javascript
augroup END

