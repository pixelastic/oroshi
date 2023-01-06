" COLORS {{{

" Enabling syntax highlighting
syntax on
colorscheme oroshi
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

" Colorize color hex codes {{{
" Where to display them
" Values: virtual, sign_column, background, backgroundfull, foreground,
" foregroundful
let g:Hexokinase_highlighters = ['backgroundfull', 'virtual']

" Which color notation to highlight
" Values: full_hex, triple_hex, rgb, rgba, hsl, hsla, colour_name
let g:Hexokinase_optInPatterns = ['full_hex']
"}}}
