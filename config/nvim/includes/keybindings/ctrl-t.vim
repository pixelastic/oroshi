" [CTRL-T] File search in the subdirectory
" Note: This is similar to [Ctrl-Shift-P], but my muscle memory in vim has
" already associated T with opening a new tab with files in the same directory,
" just like :t

nnoremap <silent> <C-T> :call fzf#run({'options': FzfRegexpSearchSubdirOptions(), 'sinklist': function('FzfRegexpSearchSubdirSink') })<CR>
inoremap <silent> <C-T> <Esc>:call fzf#run({'options': FzfRegexpSearchSubdirOptions(), 'sinklist': function('FzfRegexpSearchSubdirSink') })<CR>
" }}}
