" DEBUG COLORSCHEME
" Display the current highlight group of the word under cursor {{{
function! Debugcolor()
  echo 'From outer to inner:'
  let stack = synstack(line('.'), col('.'))

  " No highlight, simply the default one
  if len(stack) == 0
    execute 'hi Normal'
    return
  endif

  for id in synstack(line('.'), col('.'))
    let name = synIDattr(id, 'name')
    execute 'hi '.name
  endfor
endfunction
nnoremap <F3> :call Debugcolor()<CR>
