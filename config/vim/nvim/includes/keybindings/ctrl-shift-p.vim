" [CTRL-Shift-P] Files search in the subdirectory

" Initial list of sources
function! FzfFilesSearchSubdirSource()
  let fzfSource= system('fzf-fs-files-subdir-source')
  return split(fzfSource, "\n")
endfunction

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

nnoremap <silent> Ⓟ :call fzf#run({'source': FzfFilesSearchSubdirSource(), 'options': FzfFilesSearchSubdirOptions(), 'sinklist': function('FzfFilesSearchSubdirSink') })<CR>
inoremap <silent> Ⓟ <Esc>:call fzf#run({'source': FzfFilesSearchSubdirSource(), 'options': FzfFilesSearchSubdirOptions(), 'sinklist': function('FzfFilesSearchSubdirSink') })<CR>
" }}}
