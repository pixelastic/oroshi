" COMPLETION {{{
" Height of the (scrollable) autocompletion window
set pumheight=10

" Send a different key combination if Coc autocomplete is opened
function! SendCompletionKey(default_key, completion_key)
  return coc#pum#visible() ? a:completion_key : a:default_key
endfunction
" }}}
