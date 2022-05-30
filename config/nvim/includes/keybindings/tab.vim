" TAB KEY {{{
" - In a word: starts autocompletion
" - In autocompletion: move to next choice
" - After a space: adds a tab
function! MultiPurposeTab()
  " Aucompletion already open, looping through it
  if pumvisible()
    return "\<C-N>"
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
function! MultiPurposeShiftTab()
  " Aucompletion already open, going back one selection
  if pumvisible()
    return "\<C-P>"
  endif

  return "\<Esc><<^i"
endfunction
inoremap <expr> <S-Tab> (MultiPurposeShiftTab())
nnoremap <S-Tab> <<^
vnoremap <S-Tab> <gv
" }}}
