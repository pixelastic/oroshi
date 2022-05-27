" SEARCH / REPLACE  {{{
" Searchs are case-insensitive, unless an uppercase is present
set ignorecase
set smartcase
" Results are highlighted as we type as well as when found.
set incsearch
set hlsearch
" [,<Space>] clears the highlight
nnoremap <silent> <Leader><Space> :nohlsearch<CR>
" Regexps will use the extended format (no need to escape special chars to give
" them meaning - (.*) will work when \(.*\) was needed before. Also, all
" matches are global on the line, not limited to the first one.
set gdefault
nnoremap / /\v
nnoremap ? ?\v
nnoremap :s/ :s/\v
nnoremap :ù :%s/
vnoremap :ù :s/
"}}}

