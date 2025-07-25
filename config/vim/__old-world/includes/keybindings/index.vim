" KEYBINDINGS
" DEFAULT {{{
" Defining leader key
let mapleader=','
" Using the Space as a repeat key
nmap <Space> .
" }}}

source ~/.config/nvim/includes/keybindings/arrows.vim
source ~/.config/nvim/includes/keybindings/backspace.vim
source ~/.config/nvim/includes/keybindings/capslock.vim
source ~/.config/nvim/includes/keybindings/enter.vim
source ~/.config/nvim/includes/keybindings/tab.vim

source ~/.config/nvim/includes/keybindings/f1.vim           " Show help
source ~/.config/nvim/includes/keybindings/f2.vim           " Toggle colorscheme
source ~/.config/nvim/includes/keybindings/f3.vim           " Debug colorschem
source ~/.config/nvim/includes/keybindings/f4.vim           " Lint
source ~/.config/nvim/includes/keybindings/f8.vim           " Toggle hidden characters
source ~/.config/nvim/includes/keybindings/f9.vim           " Toggle line wrap

source ~/.config/nvim/includes/keybindings/ctrl-a.vim       " Select all

source ~/.config/nvim/includes/keybindings/ctrl-e.vim       " Go to next error
source ~/.config/nvim/includes/keybindings/ctrl-shift-e.vim " Go to previous error

source ~/.config/nvim/includes/keybindings/ctrl-o.vim       " Go to previous jump position

source ~/.config/nvim/includes/keybindings/ctrl-s.vim       " Save file
source ~/.config/nvim/includes/keybindings/ctrl-d.vim       " Close tab/vim
source ~/.config/nvim/includes/keybindings/ctrl-del.vim     " Delete current file

source ~/.config/nvim/includes/keybindings/ctrl-p.vim       " Fuzzy-find files in project
source ~/.config/nvim/includes/keybindings/ctrl-shift-p.vim " Fuzzy-find files in subdir
source ~/.config/nvim/includes/keybindings/ctrl-t.vim       " Alias to also fuzzy-find files in subdir

source ~/.config/nvim/includes/keybindings/ctrl-g.vim       " Regex search in project
source ~/.config/nvim/includes/keybindings/ctrl-shift-g.vim " Regex search in subdir

source ~/.config/nvim/includes/keybindings/ctrl-y.vim       " Check previous versions of the file

source ~/.config/nvim/includes/keybindings/dash.vim         " Move line above
source ~/.config/nvim/includes/keybindings/underscore.vim   " Move line below
source ~/.config/nvim/includes/keybindings/hjkl.vim         " Move around

source ~/.config/nvim/includes/keybindings/sort.vim
source ~/.config/nvim/includes/keybindings/align.vim



" VIMDIFF  {{{
" Vimdiff will mostly be used to handle merges. It is configured to be
" displayed in three panels (origin, result and other).
" Jump to next/previous change
nnoremap vdk [c
nnoremap vdj ]c
" Accept origin (left) or other (right) change
nnoremap <silent> vdh :diffget //2<CR>:diffupdate<CR>]c
nnoremap <silent> vdl :diffget //3<CR>:diffupdate<CR>]c
"}}}

" MOTIONS {{{
" Go to start and end of line with H and L
nnoremap H ^
vnoremap H ^
nnoremap L g_
vnoremap L g_
" Go back to first non blank character with home
nnoremap <Home> ^
inoremap <Home> <Esc>^i
" Scroll one page at a time
nnoremap U <C-U>
nnoremap D <C-D>
vnoremap U <C-U>
vnoremap D <C-D>
" Jump to
nnoremap <silent> <Leader>z :lprev<CR>
nnoremap <silent> <Leader>s :lnext<CR>
nnoremap <silent> <Leader>q :cprev<CR>
nnoremap <silent> <Leader>d :cnext<CR>
" Select the current block of text
nnoremap vip {jv}k$
" }}}

" MUSCLE MEMORY {{{
" KEYBOARD {{{
" Faster typing of =>
inoremap °+ =>
inoremap )= =>
inoremap +° =>
inoremap =) =>

" Add ; at the end of the line
function! AddMissingSemiColon()
  " Mark current spot (mx) and go to end of line ($)
  normal mx$
  " If current char is not already ;
  if getline('.')[col('.')-1] !=# ";"
    " Add a ; to the end of the line
    normal A;
  endif
  " Go back to previous mark
  normal `x
endfunction
nnoremap <silent> ; :call AddMissingSemiColon()<CR>;
" }}}

" NICETIES {{{
" Comment whole paragraph
nnoremap gcp vipgc
" Increment/Decrement number under cursor
nnoremap <C-J> <C-X>
nnoremap <C-K> <C-A>
" }}}
