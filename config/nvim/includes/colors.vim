" COLORS {{{

" Enabling syntax highlighting
syntax on
colorscheme oroshi
"}}}

" Colorize color hex codes {{{
" Where to display them
" Values: virtual, sign_column, background, backgroundfull, foreground,
" foregroundful
let g:Hexokinase_highlighters = ['backgroundfull', 'virtual']

" Which files and which color notation to highlight
" Values: full_hex, triple_hex, rgb, rgba, hsl, hsla, colour_name
let g:Hexokinase_ftEnabled = ['kitty', 'vim']
let g:Hexokinase_ftOptInPatterns = {
\     'kitty': 'full_hex',
\     'vim': 'full_hex'
\ }
"}}}
