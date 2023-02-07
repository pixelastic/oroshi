" [CTRL-G] Regexp search inside of files in whole project

" FZF options
function! FzfRegexpSearchProjectOptions()
  let fzfOptions= system('fzf-regexp-search-options fzf-regexp-search-project-source --vim')
  return fzfOptions
endfunction

" What to do with the selection
function! FzfRegexpSearchProjectSink(selection)
  let rawSelection=join(a:selection, "\n")
  if rawSelection ==# ''
    return
  endif

  " Parse the raw selection
  let gitRoot=GitRoot()
  let selection=system('fzf-regexp-search-postprocess '.shellescape(rawSelection).' '.gitRoot)

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
