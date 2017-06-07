" Folding {{{
" Curly braces are already used by Ansible to delimit variables, so we'll have
" to use another marker for folding.
setlocal foldmethod=marker
setlocal foldmarker=[[[,]]]
" }}}
" Cleaning the file {{{
inoremap <silent> <buffer> <F4> <Esc>:call AnsibleBeautify()<CR>
nnoremap <silent> <buffer> <F4> :call AnsibleBeautify()<CR>
function! AnsibleBeautify() 
  " Remove trailing spaces
  call RemoveTrailingSpaces()
endfunction
" }}}

