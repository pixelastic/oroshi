" [CTRL-P] Files search in the whole project

" Command to call to build the list of choices
let fzfFilesSearchProjectSource='fzf-files-search-project-source'

" FZF options
function! FzfFilesSearchProjectOptions()
  let gitRoot=GitRoot()
  let fzfOptions= system('fzf-files-search-options '. gitRoot .' --vim')
  return fzfOptions
endfunction

" What to do with the selection
function! FzfFilesSearchProjectSink(selection)
  let rawSelection=join(a:selection, "\n")
  if rawSelection ==# ''
    return
  endif

  " Parse the raw selection
  let gitRoot=GitRoot()
  let selection=system('fzf-files-search-postprocess '.shellescape(rawSelection).' '.gitRoot)

  " Open each file
  for filepath in split(selection, ' ')
    execute 'tab drop '.filepath
  endfor
endfunction

nnoremap <silent> <C-P> :call fzf#run({'source': fzfFilesSearchProjectSource, 'options': FzfFilesSearchProjectOptions(), 'sinklist': function('FzfFilesSearchProjectSink') })<CR>
inoremap <silent> <C-P> <Esc>:call fzf#run({'source': fzfFilesSearchProjectSource, 'options': FzfFilesSearchProjectOptions(), 'sinklist': function('FzfFilesSearchProjectSink') })<CR>
" }}}
