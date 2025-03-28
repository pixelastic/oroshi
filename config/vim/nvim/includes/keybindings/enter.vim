" ENTER KEY

" [Enter]
let g:endwise_no_mappings = 1 " Disable mapping on Enter set by endwise
" Pressing Enter can do several things:
" - Validate Copilot suggestion if enabled
" - Validate the current completion selection if menu is open
" - Trigger endwise otherwise
function! MultiPurposeEnter()
  if OroshiCopilotSuggestionDisplayed()
    return copilot#Accept('\<CR>')
  endif

  " Validate completion selection
  if pumvisible()
    return "\<C-Y>"
  endif

  " Auto-close if/while/functions
  return EndwiseAppend("\r")
endfunction
inoremap <silent> <script> <expr> <CR> MultiPurposeEnter()

" Add line after this one
nnoremap <CR> mzo<Esc>`z

" [Shift-Enter] Add new line before
nnoremap ↰ mzO<Esc>d$`z
inoremap ↰ <Esc>lmzO<Esc>d$`zi

" [Ctrl-Enter]
" Normal: Add new line after this char
nnoremap ↯ mzli<CR><Esc>`z

" Insert: Move to next completion bucket
inoremap <silent> <plug>(MUcompleteFwdKey) ↯
imap ↯ <plug>(MUcompleteCycFwd)
