" [CTRL-Y] Allows navigating into the file history, and pulling an old version

" Command to call to build the list of choices
function! FzfGitHistorySource()
  let fzfSource='vim-fzf-git-file-history'
  let fzfSource.=' "' . expand('%') . '"'
  return fzfSource
endfunction

" fzf options, to display colors and a preview window
function! FzfGitHistoryOptions() 
  let gitPath= StrTrim(system('git-file-path "'. expand('%') . '"'))
  let fzfOptions=''
  let fzfOptions.='--ansi '
  " let fzfOptions.="--preview-window 'right,50%,border-left,<79(bottom,80%,border-top)'"
  let fzfOptions.='--preview "git-file-history-preview {} "'. gitPath .'""'
  return fzfOptions
endfunction

" Open a new file with content at a specific commit
function! FzfGitHistorySink(selection)
  " Stop if no selection is made
  if a:selection ==# ''
    return
  endif

  " Find the commit hash
  let commitHash=split(a:selection, ' ')[1]

  " Find new filename 
  let dirname=expand('%:p:r')
  let extension=expand('%:e')
  let newFilepath=dirname.'.'.commitHash.'.'.extension
  let gitPath= StrTrim(system('git-file-path "'. expand('%') . '"'))


  " Open a new tab with the name, set the content and save it
  execute 'tabedit '.newFilepath
  execute 'read !git show '.commitHash.':"'.gitPath.'"'
  normal gg
  write
endfunction

nnoremap <silent> <C-Y> :call fzf#run({'source': FzfGitHistorySource(), 'options': FzfGitHistoryOptions(), 'sink': function('FzfGitHistorySink') })<CR>
inoremap <silent> <C-Y> <Esc>:call fzf#run({'source': FzfGitHistorySource(), 'options': FzfGitHistoryOptions(), 'sink': function('FzfGitHistorySink') })<CR>
