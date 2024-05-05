" [CTRL-T] Files search in the subdirectory

" Command to call to build the list of choices
let fzfFilesSearchSubdirSource='fzf-fs-files-subdir-source'

" FZF options
function! FzfFilesSearchSubdirOptions()
  let fzfOptions= system('fzf-fs-files-subdir-options')
  return split(fzfOptions, "\n")
endfunction

" What to do with the selection
function! FzfFilesSearchSubdirSink(selection)
  if len(a:selection) ==# 0
    return
  endif

  " Sanitize the file names from the fzf selection
  let joinedSelection=join(a:selection, "\n")
  let selection=system('fzf-fs-files-shared-postprocess '.shellescape(joinedSelection))

  " Open each file
  execute 'tab drop '.selection
endfunction

nnoremap <silent> <C-T> :call fzf#run({'source': fzfFilesSearchSubdirSource, 'options': FzfFilesSearchSubdirOptions(), 'sinklist': function('FzfFilesSearchSubdirSink') })<CR>
inoremap <silent> <C-T> <Esc>:call fzf#run({'source': fzfFilesSearchSubdirSource, 'options': FzfFilesSearchSubdirOptions(), 'sinklist': function('FzfFilesSearchSubdirSink') })<CR>
" }}}
