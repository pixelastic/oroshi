" Cleaning the file {{{
inoremap <silent> <buffer> <F4> <Esc>:call AnsibleBeautify()<CR>
nnoremap <silent> <buffer> <F4> :call AnsibleBeautify()<CR>
function! AnsibleBeautify() 
  " Remove trailing spaces
  call RemoveTrailingSpaces()
endfunction
" }}}

