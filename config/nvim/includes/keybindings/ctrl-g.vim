" [CTRL-G] Regexp search inside of files in whole project

" FZF options
function! FzfRegexpSearchProjectOptions()
  let fzfOptions= system('fzf-regexp-search-project-options')
  return split(fzfOptions, "\n")
endfunction

" What to do with the selection
function! FzfRegexpSearchProjectSink(selection)
  if len(a:selection) ==# 0
    return
  endif

  let rawSelection=join(a:selection, "\n")
  let selection=system('fzf-regexp-search-postprocess '.shellescape(rawSelection))

  " Open each file and jump to right line
  for line in split(selection, ' ')
    let lineSplit=split(line, ':')
    let filepath=lineSplit[0]
    let lineNumber=lineSplit[1]
    execute 'tab drop '.filepath
    execute lineNumber
  endfor
endfunction

nnoremap <silent> <C-G> :call fzf#run({'options': FzfRegexpSearchProjectOptions(), 'sinklist': function('FzfRegexpSearchProjectSink') })<CR>
inoremap <silent> <C-G> <Esc>:call fzf#run({'options': FzfRegexpSearchProjectOptions(), 'sinklist': function('FzfRegexpSearchProjectSink') })<CR>
" }}}
