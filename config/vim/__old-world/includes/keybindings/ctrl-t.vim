" [CTRL-T] File search in the subdirectory
" Note: This is similar to [Ctrl-Shift-P], they both do the same thing

nnoremap <silent> <C-T> :call fzf#run({'source': FzfFilesSearchSubdirSource(), 'options': FzfFilesSearchSubdirOptions(), 'sinklist': function('FzfFilesSearchSubdirSink') })<CR>
inoremap <silent> <C-T> <Esc>:call fzf#run({'source': FzfFilesSearchSubdirSource(), 'options': FzfFilesSearchSubdirOptions(), 'sinklist': function('FzfFilesSearchSubdirSink') })<CR>
" }}}
