" SEARCH / REPLACE  {{{
" Searchs are case-insensitive, unless an uppercase is present
set ignorecase
set smartcase
" Results are highlighted as we type as well as when found. ,<Space> clears the
" highlight
set incsearch
set hlsearch
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

" SEARCH {{{
" Search all files in the current project and jump to them
function! FzfCtrlPSink(line)
  " Open result in new tab, or re-use existing one if already opened
  execute "tab drop " . GetRepoRoot() . "/" . a:line
endfunction

nnoremap <silent> <C-P> :call fzf#run({'source': 'vim-fzf-ctrlp', 'sink': function('FzfCtrlPSink')})<CR>
inoremap <silent> <C-P> <Esc>:call fzf#run({'source': 'vim-fzf-ctrlp', 'sink': function('FzfCtrlPSink')})<CR>
" }}}
