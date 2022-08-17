" HIDDEN CHARACTERS {{{
" We display hidden characters
set list

" By default, only non breakable spaces, horizontal scroll markers, trailing
" spaces and multispaces
let g:default_listchars=''
let g:default_listchars .= 'eol: ,'
let g:default_listchars .= 'extends:,'
let g:default_listchars .= 'lead: ,'
let g:default_listchars .= 'multispace:,'
let g:default_listchars .= 'nbsp:∅,'
let g:default_listchars .= 'precedes:,'
let g:default_listchars .= 'tab:  ,'
let g:default_listchars .= 'trail:,'

" When F8 is pressed, we add end of lines, tabs and leading spaces
let g:extended_listchars = ''
let g:extended_listchars .= 'eol:↲,'
let g:extended_listchars .= 'extends:,'
let g:extended_listchars .= 'lead:,'
let g:extended_listchars .= 'multispace:,'
let g:extended_listchars .= 'nbsp:∅,'
let g:extended_listchars .= 'precedes:,'
let g:extended_listchars .= 'tab: ,'
let g:extended_listchars .= 'trail:,'

" Note: If there is an error in the string formatting, this will silently fail
" and revert to the default listchars (tab:> ,trail:-,nbsp:+)
let &listchars=g:default_listchars

" When pressing F8, we toggle between the default and  extended    lists
function! ToggleListChars()
  set list
  if &listchars ==# g:default_listchars
    let &listchars=g:extended_listchars
  else
    let &listchars=g:default_listchars
  endif
endfunction

nnoremap <silent> <F8> :call ToggleListChars()<CR>
vnoremap <silent> <F8> :call ToggleListChars()<CR>
inoremap <silent> <F8> <Esc>:call ToggleListChars()<CR>li

