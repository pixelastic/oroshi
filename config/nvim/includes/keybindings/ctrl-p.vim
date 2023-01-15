" Search all files in the current project and jump to them
function! FzfCtrlPSink(line)
  " Open result in new tab, or re-use existing one if already opened
  execute "tab drop " . GetRepoRoot() . "/" . a:line
endfunction

nnoremap <silent> <C-P> :call fzf#run({'source': 'vim-fzf-ctrlp', 'options': '--ansi', 'sink': function('FzfCtrlPSink')})<CR>
inoremap <silent> <C-P> <Esc>:call fzf#run({'source': 'vim-fzf-ctrlp', 'options': '--ansi', 'sink': function('FzfCtrlPSink')})<CR>
" }}}
