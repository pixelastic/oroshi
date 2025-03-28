" [CTRL-P] Files search in the whole project

" Initial list of sources
function! FzfFilesSearchProjectSource()
  let fzfSource= system('fzf-fs-files-project-source')
  return split(fzfSource, "\n")
endfunction

" FZF options
function! FzfFilesSearchProjectOptions()
  let fzfOptions= system('fzf-fs-files-project-options')
  return split(fzfOptions, "\n")
endfunction

" What to do with the selection
function! FzfFilesSearchProjectSink(selection)
  if len(a:selection) ==# 0
    return
  endif

  " Sanitize the file names from the fzf selection
  let joinedSelection=join(a:selection, "\n")
  let selection=system('fzf-fs-files-shared-postprocess '.shellescape(joinedSelection))

  " Open each file
  execute 'tab drop '.selection
endfunction

nnoremap <silent> <C-P> :call fzf#run({'source': FzfFilesSearchProjectSource(), 'options': FzfFilesSearchProjectOptions(), 'sinklist': function('FzfFilesSearchProjectSink') })<CR>
inoremap <silent> <C-P> <Esc>:call fzf#run({'source': FzfFilesSearchProjectSource(), 'options': FzfFilesSearchProjectOptions(), 'sinklist': function('FzfFilesSearchProjectSink') })<CR>
" }}}
