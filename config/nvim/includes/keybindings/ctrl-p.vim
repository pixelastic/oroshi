" [CTRL-P] Fuzzy-finder into all the git project files
" TODO: Should search above submodules
function! FzfCtrlPSink(line)
  " Open result in new tab, or re-use existing one if already opened
  execute 'tab drop ' . GetRepoRoot() . '/' . a:line
endfunction

" Command to call to build the list of choices
let fzfSource='vim-fzf-ctrlp'

" fzf options, to display colors and a preview window
let fzfOptions=''
let fzfOptions.='--ansi '
let fzfOptions.="--preview 'fzf-preview " . GetRepoRoot() ."/{}' "

nnoremap <silent> <C-P> :call fzf#run({'source': fzfSource, 'options': fzfOptions, 'sink': function('FzfCtrlPSink') })<CR>
inoremap <silent> <C-P> <Esc>:call fzf#run({'source': fzfSource, 'options': fzfOptions, 'sink': function('FzfCtrlPSink') })<CR>
" }}}
