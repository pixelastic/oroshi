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
