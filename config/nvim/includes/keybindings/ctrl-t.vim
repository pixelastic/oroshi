" [CTRL-T] Files search in the subdirectory

" Command to call to build the list of choices
let fzfFilesSearchSubdirSource='fzf-files-subdir-source'

" FZF options
function! FzfFilesSearchSubdirOptions()
  let fzfOptions= system('fzf-files-subdir-options')
  return split(fzfOptions, "\n")
endfunction

" What to do with the selection
function! FzfFilesSearchSubdirSink(selection)
  if len(a:selection) ==# 0
    return
  endif

  let rawSelection=join(a:selection, "\n")
  let selection=system('fzf-files-postprocess '.shellescape(rawSelection))

  " Open each file
  for filepath in split(selection, ' ')
    execute 'tab drop '.filepath
  endfor
endfunction

nnoremap <silent> <C-T> :call fzf#run({'source': fzfFilesSearchSubdirSource, 'options': FzfFilesSearchSubdirOptions(), 'sinklist': function('FzfFilesSearchSubdirSink') })<CR>
inoremap <silent> <C-T> <Esc>:call fzf#run({'source': fzfFilesSearchSubdirSource, 'options': FzfFilesSearchSubdirOptions(), 'sinklist': function('FzfFilesSearchSubdirSink') })<CR>
" }}}