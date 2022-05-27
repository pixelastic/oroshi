" YANK / PASTE   {{{
" Note: Systems have two different clipboards.
" unnamed is (select text / middle click) and accessed with "*
" unnamedplus is (Ctrl+C / Ctrl+V) and accessed with "+
" We only use unnamed plus, if available
set clipboard=
if has('unnamedplus')
  set clipboard+=unnamedplus
endif

vnoremap p "_dP
vnoremap P "_dP
" As gv selects last selected text, we add gp to select last pasted text
nnoremap gp `[v`]
" We'll use x as a way to delete text without keeping it in a paste buffer
nnoremap x "_x
vnoremap x "_x
" [c]hanging a word does not put it in yank buffer
nnoremap c "_c
" }}}
"}}}
