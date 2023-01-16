" [CTRL-G] Allows navigating into the file history, and pulling an old version
function! FzfCtrlGSink(line)
  " " Open result in new tab, or re-use existing one if already opened
  " execute 'tab drop ' . GetRepoRoot() . '/' . a:line
endfunction

" Command to call to build the list of choices
let s:fzfSource='fzf-vim-ctrlg'
let s:fzfSource.=' "' . expand('%') . '"'


" fzf options, to display colors and a preview window
let s:fzfOptions=''
let s:fzfOptions.='--ansi '
" let fzfOptions.="--preview 'fzf-preview " . GetRepoRoot() ."/{}' "
" let fzfOptions.='--preview-window=right '

" Sink method, called with the fzf selection
let s:fzfSink="function('FzfCtrlGSink')"

nnoremap <silent> <C-G> :call fzf#run({'source': s:fzfSource, 'options': s:fzfOptions, 'sink': s:fzfSink})<CR>
inoremap <silent> <C-G> <Esc>:call fzf#run({'source': s:fzfSource, 'options': s:fzfOptions, 'sink': s:fzfSink})<CR>
