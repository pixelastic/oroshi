scriptencoding utf-8
" [CTRL-Shift-P] Files search in the subdirectory

" Command to call to build the list of choices
let fzfFilesSearchSubdirSource='fzf-files-search-subdir-source'

" FZF options
function! FzfFilesSearchSubdirOptions()
  let subdir=expand('%:p:h')
  let fzfOptions= system('fzf-files-search-options '. subdir .' --vim')
  return fzfOptions
endfunction

" What to do with the selection
function! FzfFilesSearchSubdirSink(selection)
  let rawSelection=join(a:selection, "\n")
  if rawSelection ==# ''
    return
  endif

  " Parse the raw selection
  let subdir=expand('%:p:h')
  let selection=system('fzf-files-search-postprocess '.shellescape(rawSelection).' '.subdir)

  " Open each file
  for filepath in split(selection, ' ')
    execute 'tab drop '.filepath
  endfor
endfunction

nnoremap <silent> Ⓟ :call fzf#run({'source': fzfFilesSearchSubdirSource, 'options': FzfFilesSearchSubdirOptions(), 'sinklist': function('FzfFilesSearchSubdirSink') })<CR>
inoremap <silent> Ⓟ <Esc>:call fzf#run({'source': fzfFilesSearchSubdirSource, 'options': FzfFilesSearchSubdirOptions(), 'sinklist': function('FzfFilesSearchSubdirSink') })<CR>
" }}}
