scriptencoding utf-8
" [CTRL-Shift-G] Regexp search inside of files in current directory

" FZF options
function! FzfRegexpSearchSubdirOptions()
  let fzfOptions= system('fzf-regexp-search-options fzf-regexp-search-subdir-source --vim')
  return fzfOptions
endfunction

" What to do with the selection
function! FzfRegexpSearchSubdirSink(selection)
  let rawSelection=join(a:selection, "\n")
  if rawSelection ==# ''
    return
  endif

  " Parse the raw selection
  let subdir=expand('%:p:h')
  let selection=system('fzf-regexp-search-postprocess '.shellescape(rawSelection).' '.subdir)

  " Open each file and jump to right line
  for line in split(selection, ' ')
    let lineSplit=split(line, ':')
    let filepath=lineSplit[0]
    let lineNumber=lineSplit[1]
    execute 'tabnew '.filepath
    execute lineNumber
  endfor
endfunction

nnoremap <silent> Ⓖ :call fzf#run({'options': FzfRegexpSearchSubdirOptions(), 'sinklist': function('FzfRegexpSearchSubdirSink') })<CR>
inoremap <silent> Ⓖ <Esc>:call fzf#run({'options': FzfRegexpSearchSubdirOptions(), 'sinklist': function('FzfRegexpSearchSubdirSink') })<CR>
" }}}
