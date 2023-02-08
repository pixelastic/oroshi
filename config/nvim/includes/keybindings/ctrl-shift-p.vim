scriptencoding utf-8
" [CTRL-Shift-P] Files search in the subdirectory

" Command to call to build the list of choices
let fzfFilesSearchSubdirSource='fzf-files-search-subdir-source'

" FZF options
function! FzfFilesSearchSubdirOptions()
  let fzfOptions= system('fzf-files-search-subdir-options')
  return split(fzfOptions, "\n")
endfunction

" What to do with the selection
function! FzfFilesSearchSubdirSink(selection)
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

nnoremap <silent> Ⓟ :call fzf#run({'source': fzfFilesSearchSubdirSource, 'options': FzfFilesSearchSubdirOptions(), 'sinklist': function('FzfFilesSearchSubdirSink') })<CR>
inoremap <silent> Ⓟ <Esc>:call fzf#run({'source': fzfFilesSearchSubdirSource, 'options': FzfFilesSearchSubdirOptions(), 'sinklist': function('FzfFilesSearchSubdirSink') })<CR>
" }}}
