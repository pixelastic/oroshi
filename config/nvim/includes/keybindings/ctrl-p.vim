" [CTRL-P] Fuzzy-finder into all the git project files

" Command to call to build the list of choices
let fzfProjectFilesSource='vim-fzf-project-files'

" fzf options, to display colors and a preview window
function! FzfProjectFilesOptions()
  let gitRoot=StrTrim(system('git-directory-root -f'))
  let fzfOptions=''
  let fzfOptions.='--ansi '
  let fzfOptions.="--preview 'fzf-preview " . gitRoot ."/{}' "
  return fzfOptions
endfunction

function! FzfProjectFilesSink(selection)
  " Stop if no selection is made
  if a:selection ==# ''
    return
  endif

  let gitRoot=StrTrim(system('git-directory-root -f'))

  " Open result in new tab, or re-use existing one if already opened
  execute 'tab drop '. gitRoot. '/' . a:selection
endfunction

nnoremap <silent> <C-P> :call fzf#run({'source': fzfProjectFilesSource, 'options': FzfProjectFilesOptions(), 'sink': function('FzfProjectFilesSink') })<CR>
inoremap <silent> <C-P> <Esc>:call fzf#run({'source': fzfProjectFilesSource, 'options': FzfProjectFilesOptions(), 'sink': function('FzfProjectFilesSink') })<CR>
" }}}
