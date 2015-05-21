" XML
" Cleaning the file {{{
inoremap <silent> <buffer> <F4> <Esc>:call XMLBeautify()<CR>
nnoremap <silent> <buffer> <F4> :call XMLBeautify()<CR>
function! XMLBeautify() 
  execute '%!tidy5 -xml -i - 2>/dev/null'
endfunction
" }}}
