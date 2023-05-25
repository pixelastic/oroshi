" TAB KEY
" [Tab]
" Indent lines in normal and visual mode
nnoremap <Tab> >>^
vnoremap <Tab> >gv

" Initiate completion (or go to next choice) in insert mode
imap <Tab> <plug>(MUcompleteFwd)

" [Shift-Tab]
" Dedent lines in normal and visual mode
nnoremap <S-Tab> <<^
vnoremap <S-Tab> <gv

" Interate backward in completion
imap <S-Tab> <plug>(MUcompleteBwd)

" Old method, used when using coc {{{
" " - In a word: starts autocompletion
" " - In autocompletion: move to next choice
" " - After a space: adds a tab
" function! MultiPurposeTab()
"   " " Aucompletion already open, looping through it
"   " if coc#pum#visible()
"   "   return coc#pum#next(1)
"   " endif

"   " Start of a line, adding a real Tab
"   if (col('.') == 1)
"     return "\<Tab>"
"   endif

"   " After a space, adding a real Tab
"   let previousLetter = strpart(getline('.'), col('.') - 2, 1)
"   if (previousLetter =~# '\s')
"     return "\<Tab>"
"   endif

"   " " After a letter, opening auto-completion
"   " return coc#refresh()
" endfunction

" " Note: Somehow it is not needed to map it in command mode, it already works
" inoremap <expr> <Tab> (MultiPurposeTab())

" " Note: Somehow it is not needed to map it in command mode, it already works
" inoremap <expr> <S-Tab> SendCocCompletionKey("\<Esc><<^i", coc#pum#prev(1))
" }}}
