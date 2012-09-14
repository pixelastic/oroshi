" QUICK FIX
" Enter : open result in new tab, go to tab and close results
nnoremap <silent> <buffer> <CR> <C-W><CR><C-W>TgT:cclose<CR>gt
" t : Open result in a new tab but keep results
nnoremap <silent> <buffer> t <C-W><CR><C-W>TgT<C-W><C-W>
" q : Close the quickfix windows
nnoremap <silent> <buffer> q :cclose<CR>
