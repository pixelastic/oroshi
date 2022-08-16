" ARROWS {{{
" In autocomplete mode, we hijack arrows to act as up and down

" Autocomplete in insert mode
inoremap <expr> <Down> pumvisible() ? "\<C-N>" : "\<Down>"
inoremap <expr> <Up> pumvisible() ? "\<C-P>" : "\<Up>"

" Autocomplete in command mode (opening a file for example)
cnoremap <expr> <Down> pumvisible() ? "\<C-N>" : "\<Down>"
cnoremap <expr> <Up> pumvisible() ? "\<C-P>" : "\<Up>"
