" [CTRL-P] Files search in the whole project

" Command to call to build the list of choices
let fzfFilesSearchProjectSource='fzf-files-search-project-source'

" FZF options
function! FzfFilesSearchProjectOptions()
  let fzfOptions= system('fzf-files-search-options fzf-files-search-project-source --vim')
  return fzfOptions
endfunction

" What to do with the selection
function! FzfFilesSearchProjectSink(selection)
  " Stop if no selection is made
  if a:selection ==# ''
    return
  endif

  let gitRoot=GitRoot()

  " Open result in new tab, or re-use existing one if already opened
  execute 'tab drop '. gitRoot. '/' . a:selection
endfunction

nnoremap <silent> <C-P> :call fzf#run({'source': fzfFilesSearchProjectSource, 'options': FzfFilesSearchProjectOptions(), 'sink': function('FzfFilesSearchProjectSink') })<CR>
inoremap <silent> <C-P> <Esc>:call fzf#run({'source': fzfFilesSearchProjectSource, 'options': FzfFilesSearchProjectOptions(), 'sink': function('FzfFilesSearchProjectSink') })<CR>
" }}}
