" KEYBINDINGS
" I tend to stick to the following F keys for all languages :
"  F1 : Help page
"  F2 : Change colorscheme
"  F3 : Debug colorscheme
"  F4 : Clean file
"  F5 : Run file
"  F6 : Test file
"  F7 : NERDTree
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
" CAPS LOCK KEY {{{
" Note: Xmodmap maps Caps Lock to F15
" - Cancels autocomplete, search, command, visual
" - Restore the wrong word in spelling mode
" - Toggle normal / insert mode
function! MultiPurposeCapsLock()
  let autocomplete_cancel = "\<C-E>"
  let mode_normal = "\<Esc>l"

  " Restoring the word in spelling mode
  if &spell
    let autocomplete_cancel .= "\<Esc>uh"
  endif
  return pumvisible() ? autocomplete_cancel : mode_normal
endfunction
" F15 is mapped to ([28~) in termite/alacritty, but [1;2R in kitty
inoremap <silent> [28~ <C-R>=MultiPurposeCapsLock()<CR>
inoremap <silent> [1;2R <C-R>=MultiPurposeCapsLock()<CR>
vnoremap [28~ <Esc>
vnoremap [1;2R <Esc>
cnoremap [28~ <C-C>
cnoremap [1;2R <C-C>
nnoremap [28~ i
nnoremap [1;2R i
" }}}
" TAB {{{
" Note: On Tab press, we try to expand UltiSnips snippets, or loop through
" placeholders. Otherwise we fire the autocomplete.
function! MultiPurposeTab()
  let line = getline('.')
  let columnIndex = col('.')

  " call UltiSnips#ExpandSnippetOrJump()
  " Currently expanding a snippet
  " if g:ulti_expand_or_jump_res !=# 0
  "   return ''
  " endif

  " If the autocomplete menu is already visible, we loop through item
  if pumvisible()
    return "\<C-N>"
  endif

  " If in indentation, we return a simple tab
  if (virtcol('.') - 1) <= indent('.')
    return "\<Tab>"
  endif

  " If after a space, we return a simple tab
  if (strpart(line, 0, columnIndex) =~# '\s$')
    return "\<Tab>"
  endif

  " If looks like a filepath, launch file name autocomplete
  if line =~ '.*/\w*\%' . columnIndex . 'c'
    return "\<C-X>\<C-F>\<C-N>"
  endif

  " If currently in spellchecking mode
  if &spell
    return "\<C-X>\<C-S>\<C-N>"
  endif

  " Launch auto-complete
  return "\<C-X>\<C-O>\<C-N>"
endfunction
" Disable Tab for UltiSnips so it won't interfere
let g:UltiSnipsExpandTrigger='<C-K>'
let g:UltiSnipsJumpForwardTrigger='<C-K>'
let g:UltiSnipsJumpBackwardTrigger='<C-J>'
let g:UltiSnipsEditSplit='vertical'
" Remap Tab
inoremap <silent> <Tab> <C-R>=MultiPurposeTab()<CR>
snoremap <Tab> <Esc>:call UltiSnips#ExpandSnippetOrJump()<CR>
nnoremap <Tab> >>
nnoremap <S-Tab> <<
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv
" }}}
" RETURN KEY {{{
function! MultiPurposeReturn()
  if pumvisible()
    if &spell
      " Select current spelling and move to next
      return "\<Esc>]s"
    endif
    " Select current suggestion
    return "\<Esc>"
  endif
  " Normal CR
  return "\<CR>"
endfunction
inoremap  <C-R>=MultiPurposeReturn()<CR>
inoremap <CR> <C-R>=MultiPurposeReturn()<CR>
inoremap O2M <Esc>O<Esc>j
nnoremap <CR> mzjI<CR><Esc>k$"_d0"_x`z
nnoremap O2M mzI<CR><Esc>k"_d0"_x`zj
vnoremap <CR> <Esc>g`>o<Esc>gv
vnoremap O2M <Esc>g`<O<Esc>gv
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
" Move to next/previous method definition
nnoremap mm ]m
nnoremap MM [m
" Move to current method definition
nnoremap gm [{
" Select/Delete/Change method
nnoremap vim viB
nnoremap dim diB
nnoremap cim ciB
" Select/Delete/Change method, including header
nnoremap vam [{V%
nnoremap dam [{V%d
nnoremap cam [{V%c
" Select the current block of text
nnoremap vip {jv}k$
" Sort the current block of text
nnoremap sip {jv}k$:sort<CR>
" Go to next error
nnoremap <silent> <C-E> :lnext<CR>
" }}}
" MUSCLE MEMORY {{{
" Ctrl+S saves the file, as in most apps
if !exists('*SaveFile')
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
" FILE TYPES {{{
nnoremap <silent> <leader>fJ :set ft=javascript<CR>
nnoremap <silent> <leader>fs :set ft=sh<CR>
nnoremap <silent> <leader>fj :set ft=json<CR>
nnoremap <silent> <leader>fm :set ft=markdown<CR>
nnoremap <silent> <leader>fr :set ft=ruby<CR>
nnoremap <silent> <leader>ft :set ft=text<CR>
nnoremap <silent> <leader>fz :set ft=zsh<CR>
" }}}
" YANKS {{{
vnoremap p "_dP
vnoremap P "_dP
" }}}
" KEYBOARD {{{
" F1 is easier to type than Ctrl+] to navigate between help tags.
nnoremap <F1> <C-]>
" Those keys are useless in vim but are easily accessible on a french
" keyboard. We'll remap them to switch the maj version to the non-maj version.
" Note: This mapping does not work in a macro. There seem to have issues with
" accented characters mapped and used in macros.
nnoremap ù %
vnoremap ù %
nnoremap à 0
vnoremap à 0
" Faster typing of ->
" inoremap -_ ->
" inoremap _- ->
" Faster typing of =>
inoremap °+ =>
inoremap )= =>
inoremap +° =>
inoremap =) =>
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
" Swap two words
nnoremap <C-w> daWf<Space>pB
nnoremap <C-b> daW2F<Space>pB
" appending a missing ; at the end of line
function! AppendMissingSemicolon()
  if getline('.') !~# ';$'
    execute "normal mzA;\<Esc>`z"
  endif
endfunction
nnoremap <silent> ; :call AppendMissingSemicolon()<CR>
" Comment whole paragraph
nnoremap gcp vipgc
" md will convert the selection to markdown
vnoremap <silent> md :!markdown<CR>
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
"
" Sort selection (using version sort)
vnoremap s :!sort -V<CR>
" Remove duplicate lines
vnoremap u :sort u<CR>
" Randomize lines
vnoremap r :!shuf<CR>
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
nnoremap K <nop>
" }}}
