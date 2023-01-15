" Search all files in the current project and jump to them
function! FzfCtrlPSink(line)
  " Open result in new tab, or re-use existing one if already opened
  execute 'tab drop ' . GetRepoRoot() . '/' . a:line
endfunction

" fzf options, to display colors and a preview window
let fzfOptions=''
let fzfOptions.='--ansi '
let fzfOptions.="--preview 'fzf-preview " . GetRepoRoot() ."/{}' "
let fzfOptions.='--preview-window=right '

nnoremap <silent> <C-P> :call fzf#run({'source': 'vim-fzf-ctrlp', 'options': fzfOptions, 'sink': function('FzfCtrlPSink')})<CR>
inoremap <silent> <C-P> <Esc>:call fzf#run({'source': 'vim-fzf-ctrlp', 'options': fzfOptions, 'sink': function('FzfCtrlPSink')})<CR>
" }}}
