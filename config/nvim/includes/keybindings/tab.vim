" TAB KEY
" [Tab]
" Disable default Copilot <Tab> mapping
let g:copilot_no_tab_map = v:true
" Tell Copilot it's okay, we'll still have a mapping for it (otherwise it justs
" silently disable the plugin)
let g:copilot_assume_mapped = v:true

" Indent lines in normal and visual mode
nnoremap <Tab> >>^
vnoremap <Tab> >gv

" Pressing Tab can do several things, by order of importance
" - Get to next Copilot suggestion if enabled
" - Get to next completion suggestion
" - Insert a real <Tab> character
function! MultiPurposeTab()
  if OroshiCopilotSuggestionDisplayed()
    return copilot#Next()
  endif

  call mucomplete#tab_complete(1)
endfunction
inoremap <Tab> <Cmd>call MultiPurposeTab()<CR>

" [Shift-Tab]
" Dedent lines in normal and visual mode
nnoremap <S-Tab> <<^
vnoremap <S-Tab> <gv

" Interate backward in completion
function! MultiPurposeShiftTab()
  if OroshiCopilotSuggestionDisplayed()
    return copilot#Previous()
  endif

  call mucomplete#tab_complete(-1)
endfunction
inoremap <S-Tab> <Cmd>call MultiPurposeShiftTab()<CR>
