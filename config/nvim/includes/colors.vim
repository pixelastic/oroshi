" COLORS {{{

" Enabling syntax highlighting
syntax on
colorscheme oroshi
" FUNCTIONS {{{
" Reloading the colorscheme
function! ReloadColorScheme(scheme)
  silent! mkview!
  execute 'colorscheme '.a:scheme
  silent! loadview
endfunction
" }}}

" [F2] Toggle between Light and Dark themes {{{
function! ToggleColorScheme()
  if g:colors_name ==# 'oroshi'
    call ReloadColorScheme('lucius')
    LuciusLightHighContrast
    return
  endif
  call ReloadColorScheme('oroshi')
endfunction
nnoremap <silent> <F2> :call ToggleColorScheme()<CR>
inoremap <silent> <F2> <Esc>:call ToggleColorScheme()<CR>li
" }}}
" [F3] Display the current highlight group of the word under cursor {{{
function! Debugcolor()
  echo "From outer to inner:"
  let stack = synstack(line('.'), col('.'))

  " No highlight, simply the default one
  if len(stack) == 0
    execute 'hi Normal'
    return
  endif

  for id in synstack(line('.'), col('.'))
    let name = synIDattr(id, "name")
    execute "hi ".name
  endfor
endfunction
nnoremap <F3> :call Debugcolor()<CR>
"}}}

"}}}
