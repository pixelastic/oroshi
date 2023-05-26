" [CTRL-F] Regexp search inside of files in current directory

" FZF options
function! FzfRegexpSearchSubdirOptions()
  let fzfOptions= system('fzf-regexp-subdir-options')
  return split(fzfOptions, "\n")
endfunction

" What to do with the selection
function! FzfRegexpSearchSubdirSink(selection)
  if len(a:selection) ==# 0
    return
  endif

  let rawSelection=join(a:selection, "\n")
  let selection=system('fzf-regexp-postprocess '.shellescape(rawSelection))

  " Open each file and jump to right line
  for line in split(selection, ' ')
    let lineSplit=split(line, ':')
    let filepath=lineSplit[0]
    let lineNumber=lineSplit[1]
    execute 'tab drop '.filepath
    execute lineNumber
  endfor
endfunction

nnoremap <silent> <C-F> :call fzf#run({'options': FzfRegexpSearchSubdirOptions(), 'sinklist': function('FzfRegexpSearchSubdirSink') })<CR>
inoremap <silent> <C-F> <Esc>:call fzf#run({'options': FzfRegexpSearchSubdirOptions(), 'sinklist': function('FzfRegexpSearchSubdirSink') })<CR>
" }}}
