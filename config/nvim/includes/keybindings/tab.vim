" TAB KEY {{{
~/.oro0
"
" - In a word: starts autocompletion
" - In autocompletion: move to next choice
" - After a space: adds a tab
function! MultiPurposeTab()
  " " Aucompletion already open, looping through it
  " if pumvisible()
  "   return "\<C-N>"
  " endif

  " " Start of a line, adding a real Tab
  " if (col('.') == 1)
  "   return "\<Tab>"
  " endif

  " " After a space, adding a real Tab
  " let previousLetter = strpart(getline('.'), col('.') - 2, 1)
  " if (previousLetter =~# '\s')
  "   return "\<Tab>"
  " endif

  " After a letter, opening auto-completion
  return coc#refresh()
endfunction

function! MultiPurposeShiftTab()
  " Aucompletion already open, going back one selection
  if pumvisible()
    return "\<C-P>"
  endif

  return "\<S-Tab>"
endfunction
" Remap Tab
inoremap <expr> <Tab> (MultiPurposeTab())
inoremap <expr> <S-Tab> (MultiPurposeShiftTab())
nnoremap <Tab> >>
nnoremap <S-Tab> <<
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv
" }}}
