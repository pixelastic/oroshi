" ARROWS {{{
"
" AUTOCOMPLETE
" In autocomplete mode, we hijack arrows to act as up and down in the menu

" TODO: Those keybindings are disabled while I disable CoC
" Insert mode autocomplete
" inoremap <expr> <Up> SendCocCompletionKey("\<Up>", coc#pum#prev(1))
" inoremap <expr> <Right> SendCocCompletionKey("\<Right>", coc#pum#next(1))
" inoremap <expr> <Down> SendCocCompletionKey("\<Down>", coc#pum#next(1))
" inoremap <expr> <Left> SendCocCompletionKey("\<Left>", coc#pum#prev(1))

" Command mode autocomplete
" cnoremap <expr> <Up> SendPumCompletionKey("\<Up>", "\<C-P>")
" cnoremap <expr> <Right> SendPumCompletionKey("\<Right>", "\<C-N>")
" cnoremap <expr> <Down> SendPumCompletionKey("\<Down>", "\<C-N>")
" cnoremap <expr> <Left> SendPumCompletionKey("\<Left>", "\<C-P>")

" NORMAL MODE
" Use Arrow in normal mode to move accros splits
nnoremap <Up> <C-W>k
nnoremap <Right> <C-W>l
nnoremap <Down> <C-W>j
nnoremap <Left> <C-W>h
