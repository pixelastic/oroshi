" TEXT WRAPPING {{{
" We define the expected maximum line length
set textwidth=80
" Display a visual clue to indicate where the cut will happen
set colorcolumn=81
" Always keep at least 15 characters displayed right and left of the cursor
set sidescrolloff=15

" Configure when and how this maximum width should apply
set formatoptions=
" c : Applies to comments only
set formatoptions+=c
" r : Pressing <Enter> in a comment creates a new comment line
set formatoptions+=r
" o : Pression o in normal mode in a comment creates a new comment line
set formatoptions+=o
" q : Comments can be re-wrapped using gq
set formatoptions+=q
" n : Handles list while formatting
set formatoptions+=n
" 1 : Do not end lines with one-char words
set formatoptions+=1

" Format whole paragraph
nnoremap gqp mzvipgq`z
"}}}
