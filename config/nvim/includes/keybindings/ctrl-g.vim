scriptencoding utf-8
" [CTRL-G] Regexp search inside of files

" FZF options
function! FzfRegexpSearchOptions()
  let pwd=expand('%:p:h')
  let fzfOptions=''
  let fzfOptions.='--disabled '
  let fzfOptions.='--delimiter="   " '
  let fzfOptions.='--with-nth=3 '
  let fzfOptions.="--bind \"change:reload:sleep 0.1; fzf-regexp-search-source {q} || true\" "
  return fzfOptions
endfunction

" What to do with the selection
function! FzfRegexpSearchSink(selection)
  " Stop if no selection is made
  if a:selection ==# ''
    return
  endif

  echom "===="
  echom a:selection
  echom "===="

  for line in a:selection
    echom line
  endfor


" # We only need to keep the filepath from the selections
" typeset -aU selection
" local selection=()
" for line in ${(f)rawSelection}; do
"   local split=(${(@s/   /)line})
"   local filepath="${gitRoot}/$split[1]"
"   # Skip selections that are not files (this can happen when selecting
"   # a separator)
"   [[ ! -r $filepath ]] && continue
"   selection+=($filepath)
" done


  " let pwd=expand('%:p:h')

  " " Open result in new tab, or re-use existing one if already opened
  " execute 'tab drop '. pwd. '/' . a:selection
endfunction

nnoremap <silent> <C-G> :call fzf#run({'options': FzfRegexpSearchOptions(), 'sink': function('FzfRegexpSearchSink') })<CR>
inoremap <silent> <C-G> <Esc>:call fzf#run({'options': FzfRegexpSearchOptions(), 'sink': function('FzfRegexpSearchSink') })<CR>
" }}}
