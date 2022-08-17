" COMPLETION {{{
" Height of the (scrollable) autocompletion window
set pumheight=10

" Send a different key combination if the autocomplete menu is open
" We need two methods, one for Coc and one for the default menu as they work
" differently
function! SendCocCompletionKey(default_key, completion_key)
  return coc#pum#visible() ? a:completion_key : a:default_key
endfunction

function! SendPumCompletionKey(default_key, completion_key)
  return pumvisible() ? a:completion_key : a:default_key
endfunction

" }}}
