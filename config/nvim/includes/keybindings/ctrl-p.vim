" [CTRL-P] Files search in the whole project

" Command to call to build the list of choices
let fzfFilesSearchProjectSource='fzf-files-search-project-source'

" FZF options
function! FzfFilesSearchProjectOptions()
  let fzfOptions= system('fzf-files-search-options')
  return split(fzfOptions, "\n")
endfunction

" What to do with the selection
function! FzfFilesSearchProjectSink(selection)
  if len(a:selection) ==# 0
    return
  endif

  let rawSelection=join(a:selection, "\n")
  let selection=system('fzf-files-search-postprocess '.shellescape(rawSelection))

  " Open each file
  for filepath in split(selection, ' ')
    execute 'tab drop '.filepath
  endfor
endfunction

nnoremap <silent> <C-P> :call fzf#run({'source': fzfFilesSearchProjectSource, 'options': FzfFilesSearchProjectOptions(), 'sinklist': function('FzfFilesSearchProjectSink') })<CR>
inoremap <silent> <C-P> <Esc>:call fzf#run({'source': fzfFilesSearchProjectSource, 'options': FzfFilesSearchProjectOptions(), 'sinklist': function('FzfFilesSearchProjectSink') })<CR>
" }}}
