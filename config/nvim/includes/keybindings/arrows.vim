" ARROWS {{{
"
" AUTOCOMPLETE
" In autocomplete mode, we hijack arrows to act as up and down in the menu

" Insert mode autocomplete
inoremap <expr> <Up> SendCompletionKey("\<Up>", coc#pum#prev(1))
inoremap <expr> <Right> SendCompletionKey("\<Right>", coc#pum#next(1))
inoremap <expr> <Down> SendCompletionKey("\<Down>", coc#pum#next(1))
inoremap <expr> <Left> SendCompletionKey("\<Left>", coc#pum#prev(1))

" Command mode autocomplete
" TODO: Doesn't seem to work
cnoremap <expr> <Up> SendCompletionKey("\<Up>", coc#pum#prev(1))
cnoremap <expr> <Right> SendCompletionKey("\<Right>", coc#pum#next(1))
cnoremap <expr> <Down> SendCompletionKey("\<Down>", coc#pum#next(1))
cnoremap <expr> <Left> SendCompletionKey("\<Left>", coc#pum#prev(1))

" NORMAL MODE
" Use Arrow in normal mode to move accros splits
nnoremap <Up> <C-W>k
nnoremap <Right> <C-W>l
nnoremap <Down> <C-W>j
nnoremap <Left> <C-W>h
