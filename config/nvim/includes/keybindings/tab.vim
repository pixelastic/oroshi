" TAB KEY {{{
" - In a word: starts autocompletion
" - In autocompletion: move to next choice
" - After a space: adds a tab
function! MultiPurposeTab()
  " Aucompletion already open, looping through it
  if coc#pum#visible()
    return coc#pum#next(1)
  endif

  " Start of a line, adding a real Tab
  if (col('.') == 1)
    return "\<Tab>"
  endif

  " After a space, adding a real Tab
  let previousLetter = strpart(getline('.'), col('.') - 2, 1)
  if (previousLetter =~# '\s')
    return "\<Tab>"
  endif

  " After a letter, opening auto-completion
  return coc#refresh()
endfunction

inoremap <expr> <Tab> (MultiPurposeTab())
nnoremap <Tab> >>^
vnoremap <Tab> >gv


" [Shift-Tab]
inoremap <expr> <S-Tab> SendCompletionKey("\<Esc><<^i", coc#pum#prev(1))
nnoremap <S-Tab> <<^
vnoremap <S-Tab> <gv
" }}}
