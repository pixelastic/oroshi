" Sort selection (using version sort)
vnoremap s :!sort -V<CR>

" Sort lines by line length
vnoremap L :!sort-by-length<CR>

" Remove duplicate lines
vnoremap u :sort u<CR>

" Randomize lines
vnoremap R :!shuf<CR>

" Number lines
vnoremap n :!cat -n<CR>

" Align selection on spaces
vnoremap <Space> :call AlignVisualSelectionOnSpaces()<CR>
function! AlignVisualSelectionOnSpaces()
  " Align can't natively align on spaces, so we'll replace spaces with § and
  " align on those instead, then remove them.
  silent! execute "'<,'>s/ \\+/§/"
  silent! execute "'<,'>Align §"
  silent! execute "'<,'>s/§//"
endfunction
