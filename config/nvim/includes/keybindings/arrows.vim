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

" Default arrows are disabled
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

" [Ctrl-Arrows] To move across splits
nnoremap <silent> <C-Up> <C-W>k
nnoremap <silent> <C-Right> <C-W>l
nnoremap <silent> <C-Down> <C-W>j
nnoremap <silent> <C-Left> <C-W>h

" [Ctrl-Shift-Arrows] To resize splits
nnoremap <silent> ⍐ <C-W>5+
nnoremap <silent> ⍈ <C-W>5>
nnoremap <silent> ⍗ <C-W>5-
nnoremap <silent> ⍇ <C-W>5-
