" [CTRL-P] Fuzzy find files in the whole project
" TODO: Update the name of the tab when doing a fzf search

" Command to call to build the list of choices
let fzfProjectFilesSource='fzf-files-search-project-source'

" FZF options
function! FzfProjectFilesOptions()
  let gitRoot=GitRoot()
  let fzfOptions=''
  let fzfOptions.="--preview 'fzf-files-search-project-preview " . gitRoot ."/{}' "
  return fzfOptions
endfunction

" What to do with the selection
function! FzfProjectFilesSink(selection)
  " Stop if no selection is made
  if a:selection ==# ''
    return
  endif

  let gitRoot=GitRoot()

  " Open result in new tab, or re-use existing one if already opened
  execute 'tab drop '. gitRoot. '/' . a:selection
endfunction

nnoremap <silent> <C-P> :call fzf#run({'source': fzfProjectFilesSource, 'options': FzfProjectFilesOptions(), 'sink': function('FzfProjectFilesSink') })<CR>
inoremap <silent> <C-P> <Esc>:call fzf#run({'source': fzfProjectFilesSource, 'options': FzfProjectFilesOptions(), 'sink': function('FzfProjectFilesSink') })<CR>
" }}}
