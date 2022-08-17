" TOGGLE COLORSCHEMES
" Oroshi is my preferred colorscheme, but Lucius is a nice light theme
function! ToggleColorScheme()
  silent! mkview!

  if g:colors_name ==# 'oroshi'
    colorscheme lucius
    LuciusLightHighContrast
  else
    colorscheme oroshi
  endif

  silent! loadview
endfunction

nnoremap <silent> <F2> :call ToggleColorScheme()<CR>
inoremap <silent> <F2> <Esc>:call ToggleColorScheme()<CR>li
