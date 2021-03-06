" KEYBINDINGS
" I tend to stick to the following F keys for all languages :
"  F1 : Help page or float
"  F2 : Change colorscheme
"  F3 : Debug colorscheme
"  F4 : Clean file
"  F5 : Run file
"  F6 : Copy current file:line to clipboard
"  F7 : Show error
"  F8 : Display hidden chars
"  F9 : Toggle wrap
"
" -----------------------------------------------------------------------------
" DEFAULT {{{
" Defining leader key
let mapleader=','
" Using the Space as a repeat key
nmap <Space> .
" }}}
" TABS {{{
" Switch tab with CTRL-H/CTRL-L
nnoremap <C-H> gT
nnoremap <C-L> gt
inoremap <C-H> <Esc>gT
inoremap <C-L> <Esc>gt
cnoremap <C-H> <C-C>gT
cnoremap <C-L> <C-C>gt
" Move tabs with CTRL-LEFT/CTRL-RIGHT
" Note: CTRL-J/CTRL-K is already used for incrementing/decrementing and there is
" no way to map CTRL-MAJ-* differently than CTRL-*
nnoremap <silent> <C-Left> :-tabmove<CR>
nnoremap <silent> <C-Right> :+tabmove<CR>
inoremap <silent> <C-Left> <Esc>:-tabmove<CR>
inoremap <silent> <C-Right> <Esc>:+tabmove<CR>
" }}}
" CAPS LOCK {{{
" .oroshi/config/xmodmap/xmodmaprc maps CAPS LOCK to F16 ([1;2S)
inoremap <silent> [1;2S <Esc>l
nnoremap [1;2S i
vnoremap [1;2S <Esc>
cnoremap [1;2S <Esc>
onoremap [1;2S <Esc>
" }}}
" TAB KEY {{{
"
" - In a word: starts autocompletion
" - In autocompletion: move to next choice
" - After a space: adds a tab
function! MultiPurposeTab()
  " Aucompletion already open, looping through it
  if pumvisible()
    return "\<C-N>"
  endif

  " Start of a line, adding a real Tab
  if (col('.') == 1)
    return "\<Tab>"
  endif

  " After a space, adding a real Tab
  let previousLetter = strpart(getline('.'), col('.') - 2, 1)
  if (previousLetter =~# '\s')
    return "\<Tab>"
  endif

  " After a letter, opening auto-completion
  return coc#refresh()
endfunction
function! MultiPurposeShiftTab()
  " Aucompletion already open, going back one selection
  if pumvisible()
    return "\<C-P>"
  endif

  return "\<S-Tab>"
endfunction
" Remap Tab
inoremap <expr> <Tab> (MultiPurposeTab())
inoremap <expr> <S-Tab> (MultiPurposeShiftTab())
nnoremap <Tab> >>
nnoremap <S-Tab> <<
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv
" }}}
" ARROWS {{{
function! MultiPurposeDown()
  let simple_down = "\<Down>"
  let autocomplete_down_one_line = "\<C-N>"
  return pumvisible() ? autocomplete_down_one_line : simple_down
endfunction
function! MultiPurposeUp()
  let simple_up = "\<Up>"
  let autocomplete_up_one_line = "\<C-P>"
  return pumvisible() ? autocomplete_up_one_line : simple_up
endfunction
inoremap <expr> <Down> (MultiPurposeDown())
inoremap <expr> <Up> (MultiPurposeUp())
" }}}
" RETURN KEY {{{
" - Select completion if completion menu open
" - Normal new line otherwise (defers to endwise calling)
let g:endwise_no_mappings = 1
function! MultiPurposeEnter()
  if pumvisible() 
    return "\<C-y>" 
  endif
  return "\<CR>\<Plug>DiscretionaryEnd"
endfunction
imap <expr> <CR> (MultiPurposeEnter())
" Add line after this one
nnoremap <CR> mzo<Esc>`z
" Shift-Enter: Add new line before
nnoremap [13;2u mzO<Esc>`z
inoremap [13;2u <Esc>lmzO<Esc>`zi
" Ctrl-Enter: Add new line after this char
nnoremap [13;5u mzli<CR><Esc>`z
" }}}
" F6: Current file:line {{{
function! CopyFileAndLine()
  let @+ = expand('%:p').':'.line('.')
endfunction
inoremap <silent> <F6> <Esc>:call CopyFileAndLine()<CR>
nnoremap <silent> <F6> :call CopyFileAndLine()<CR>
" }}}
" H/J/K/L {{{
function! MultiPurposeJ()
  let simple_j = 'j'
  let autocomplete_down_one_line = "\<C-N>"
  return pumvisible() ? autocomplete_down_one_line : simple_j
endfunction
function! MultiPurposeK()
  let simple_k = 'k'
  let autocomplete_up_one_line = "\<C-P>"
  return pumvisible() ? autocomplete_up_one_line : simple_k
endfunction
" Move down/up including wrapped lines
inoremap <expr> j (MultiPurposeJ())
inoremap <expr> k (MultiPurposeK())
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk
" }}}
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
nnoremap [1~ ^
inoremap <Home> <Esc>^i
inoremap [1~ <Esc>^i
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
" Ctrl+S saves the file, as in most apps
" Note: We wrap the function definition in an exists() because defining the
" function with function! like we usually do fails here because it is attempting
" to redefine itself while being in use
if !exists("*SaveFile")
  function SaveFile()
    if &diff | only | endif
    write!
  endfunction
endif
nnoremap <silent> <C-S> :call SaveFile()<CR>
inoremap <silent> <C-S> <Esc>:call SaveFile()<CR>
" Ctrl+D is save and exit, as in the term.
function! SaveAndCloseFile()
  " Keeping only one window in diff before closing
  if &diff | only | endif
  " Force quit without saving if file is not saved
  if empty(@%)
    quit!
    return
  endif
  " Save and exit
  exit!
endfunction
nnoremap <silent> <C-D> :call SaveAndCloseFile()<CR>
inoremap <silent> <C-D> <Esc>:call SaveAndCloseFile()<CR>
" Select all
nnoremap <C-A> GVgg
vnoremap <C-A> <Esc>GVgg
" }}}
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
" OPTIONS {{{
" Toggle non-printable chars
nnoremap <silent> <F8> :set list!<CR>
vnoremap <silent> <F8> :set list!<CR>
inoremap <silent> <F8> <Esc>:set list!<CR>li
" Toggle wrapping
nnoremap <silent> <F9> :set wrap!<CR>
vnoremap <silent> <F9> :set wrap!<CR>
inoremap <silent> <F9> <Esc>:set wrap!<CR>li
" }}}
" NICETIES {{{
" Move a line below with _ and up with -, keeping indentation
" Note : uses vim-unimpaired
" Latest vim has an issue with this and the folding when folding is different
" from "manual". cf. https://github.com/tpope/vim-unimpaired/issues/96
" Workaround is to set fold to manual before moving and then reverting it
function! WorkaroundForMovingLines(command)
  let foldmethod_backup=&l:foldmethod
  setlocal foldmethod=manual
  execute 'normal ' . a:command
  let &l:foldmethod=foldmethod_backup
endfunction
nmap <silent> - :call WorkaroundForMovingLines('[e')<CR>
vmap <silent> - :call WorkaroundForMovingLines('[egv')<CR>
nmap <silent> _ :call WorkaroundForMovingLines(']e')<CR>
vmap <silent> _ :call WorkaroundForMovingLines(']egv')<CR>
" Comment whole paragraph
nnoremap gcp vipgc
" Increment/Decrement number under cursor
nnoremap <C-J> <C-X>
nnoremap <C-K> <C-A>
" Align selection on spaces
vnoremap <Space> :call AlignVisualSelectionOnSpaces()<CR>
function! AlignVisualSelectionOnSpaces()
  " Align can't natively align on spaces, so we'll replace spaces with § and
  " align on those instead, then remove them.
  silent! execute "'<,'>s/ \\+/§/"
  silent! execute "'<,'>Align §"
  silent! execute "'<,'>s/§//"
endfunction
" }}}
" SORTING {{{
" Sort selection (using version sort)
vnoremap s :!sort -V<CR>
" Remove duplicate lines
vnoremap u :sort u<CR>
" Randomize lines
vnoremap R :!shuf<CR>
" Sort lines by line length
vnoremap L :!sort-by-length<CR>
" Number lines
vnoremap n :!cat -n<CR>
" }}}

" PLUGINS {{{
" Preventing Align from loading the whole list of its mappings
let g:loaded_AlignMapsPlugin = '1'
" }}}
" UNBINDING {{{
" K lookup for the word under cursor, I don't need it
" nnoremap K <nop>
" }}}
