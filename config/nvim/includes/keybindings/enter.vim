" ENTER KEY {{{
" - Select completion if completion menu open
" - Normal new line otherwise (defers to endwise calling)
let g:endwise_no_mappings = 1
function! MultiPurposeEnter()
  if coc#pum#visible()
    echom coc#pum#info()
    return coc#pum#confirm()
  endif
  return "\<CR>\<Plug>DiscretionaryEnd"
endfunction
imap <expr> <CR> (MultiPurposeEnter())
" Add line after this one
nnoremap <CR> mzo<Esc>`z
" Shift-Enter: Add new line before
nnoremap ↰ mzO<Esc>`z
inoremap ↰ <Esc>lmzO<Esc>`zi
" Ctrl-Enter: Add new line after this char
nnoremap ↯ mzli<CR><Esc>`z
" }}}