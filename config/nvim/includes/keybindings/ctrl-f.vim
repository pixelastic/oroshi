" [CTRL-F] Fuzzy-find files in subdirectories
" TODO: Update the name of the tab when doing a fzf search
" TODO: Open several files at once

" Command to call to build the list of choices
let fzfSubdirFilesSource='fzf-files-subdir-source'

" FZF options
function! FzfSubdirFilesOptions()
  let pwd=expand('%:p:h')
  let fzfOptions=''
  let fzfOptions.="--preview 'fzf-files-subdir-preview " . pwd ."/{}' "
  return fzfOptions
endfunction

" What to do with the selection
function! FzfSubdirFilesSink(selection)
  " Stop if no selection is made
  if a:selection ==# ''
    return
  endif

  echom a:selection

  let pwd=expand('%:p:h')

  " Open result in new tab, or re-use existing one if already opened
  execute 'tab drop '. pwd. '/' . a:selection
endfunction

nnoremap <silent> <C-F> :call fzf#run({'source': fzfSubdirFilesSource, 'options': FzfSubdirFilesOptions(), 'sink': function('FzfSubdirFilesSink') })<CR>
inoremap <silent> <C-F> <Esc>:call fzf#run({'source': fzfSubdirFilesSource, 'options': FzfSubdirFilesOptions(), 'sink': function('FzfSubdirFilesSink') })<CR>
" }}}
