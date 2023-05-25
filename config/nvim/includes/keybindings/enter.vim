" ENTER KEY

" [Enter]
let g:endwise_no_mappings = 1 " Disable mapping on Enter set by endwise
" Pressing Enter does two things:
" - Validate the current completion selection if menu is open
" - Trigger endwise otherwise
function! MultiPurposeEnter()
  if pumvisible() | return "\<C-Y>" | endif " Validate completion selection
  return EndwiseAppend("\r")                " Auto-close if/while/functions
endfunction
inoremap <silent> <script> <expr> <CR> MultiPurposeEnter()

" Add line after this one
nnoremap <CR> mzo<Esc>`z

" [Shift-Enter] Add new line before
nnoremap ↰ mzO<Esc>d$`z
inoremap ↰ <Esc>lmzO<Esc>d$`zi

" [Ctrl-Enter] Add new line after this char
nnoremap ↯ mzli<CR><Esc>`z
