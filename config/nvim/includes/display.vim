" DISPLAY {{{
" Display line number
set number
" Always display the gutter, for consistent rendering
set signcolumn=yes
" Show more info about current command
set showcmd
" Keep working line as vertically centered as possible
set scrolloff=999

" Hide invisible characters by default (F8 will toggle that)
set nolist
set listchars=
" Tab characters
set listchars+=tab: 
" Leading and trailing spaces
set listchars+=lead:·
set listchars+=trail:
" Multiple spaces
set listchars+=multispace:
" Non-breakable spaces
set listchars+=nbsp:∅
set listchars+=eol:↲
" Horizontal scroll markers
set listchars+=precedes:
set listchars+=extends:

" Chars used for GUI
set fillchars=stl:\ ,stlnc:\ ,vert:\|,fold:\ ,diff:-
" }}}
