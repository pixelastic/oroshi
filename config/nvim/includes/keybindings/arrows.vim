" ARROWS
" Default arrows are disabled
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

" [Up] and [Down] can be used to navigate through completion items
inoremap <expr> <Down> pumvisible() ? "\<C-N>" : "\<Down>"
inoremap <expr> <Up> pumvisible() ? "\<C-P>" : "\<Up>"

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
