" TEXT WRAPPING {{{
" Lines too long to fit on one screen will be truncated.
set nowrap
let &showbreak='↪ '
" Force a 79 column policy with an auto-break on words in comments to assure
" maximum readability. Visually add a column to see where the cut will be.
set linebreak
set colorcolumn=81
set textwidth=80
" Create two format modes, for code and for text
" c : Comments are wrapped based on textwidth
" r : New line in comment is a comment when pressing <Enter>
" o : New line in comment is a comment when pressing 'o'
" n : Handles list while formatting
" q : Comments can be re-wrapped using gq
" 1 : Do not end lines with one-char words
set formatoptions=cronq1
" We make sure that backspace in insert mode can delete new lines and tabs
set backspace=indent,eol,start
" Format whole paragraph
nnoremap gqp mzvipgq`z
"}}}
