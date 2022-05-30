" KEYBINDINGS
"  [F1] Help
"  [F2] Toggle colorscheme
"  [F3] Debug colorscheme
"  [F4] Clean file
"  [F5] Run file
"  [F6] N/A
"  [F7] Show error
"  [F8] Display hidden chars
"  [F9] Toggle wrap
" -----------------------------------------------------------------------------

" DEFAULT {{{
" Defining leader key
let mapleader=','
" Using the Space as a repeat key
nmap <Space> .
" }}}

source ~/.config/nvim/includes/keybindings/capslock.vim
source ~/.config/nvim/includes/keybindings/enter.vim
source ~/.config/nvim/includes/keybindings/tab.vim

source ~/.config/nvim/includes/keybindings/f1.vim
source ~/.config/nvim/includes/keybindings/f6.vim
source ~/.config/nvim/includes/keybindings/f8.vim
source ~/.config/nvim/includes/keybindings/f9.vim

source ~/.config/nvim/includes/keybindings/ctrl-s.vim
source ~/.config/nvim/includes/keybindings/ctrl-p.vim
source ~/.config/nvim/includes/keybindings/ctrl-d.vim
source ~/.config/nvim/includes/keybindings/ctrl-a.vim

source ~/.config/nvim/includes/keybindings/dash.vim
source ~/.config/nvim/includes/keybindings/underscore.vim
source ~/.config/nvim/includes/keybindings/hjkl.vim

source ~/.config/nvim/includes/keybindings/lines.vim



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
" Go to next error
nnoremap <silent> <C-E> :lnext<CR>
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


" PLUGINS {{{
" Preventing Align from loading the whole list of its mappings
let g:loaded_AlignMapsPlugin = '1'
" }}}
