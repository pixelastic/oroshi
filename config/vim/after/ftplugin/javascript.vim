" JAVASCRIPT
" Indentation rules {{{
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab
setlocal equalprg=js-beautify\ -f\ -
" }}}
" TernJS {{{
nnoremap <buffer> tr :TernRename<CR>
nnoremap <buffer> td :TernDef<CR>
nnoremap <buffer> tt :TernType<CR>
nnoremap <buffer> tg :TernRefs<CR>
" }}}
" Folding {{{
setlocal foldmethod=syntax
setlocal foldlevelstart=99
setlocal foldtext=JavascriptFoldText()
function! JavascriptFoldText()
  let output = getline(v:foldstart)
  let lines = v:foldend - v:foldstart
  let output = substitute(output, '{$', '{...' . lines . '}', '')
  let output = substitute(output, '[$', '[...' . lines . ']', '')
  return output
endfunction
" }}}
" Rainbow parentheses {{{
if exists(':RainbowParenthesesToggle')
  augroup rainbow_parentheses_javascript
    au!
    au Syntax <buffer> syntax clear jsFuncBlock
    au Syntax <buffer> RainbowParenthesesLoadRound
    au Syntax <buffer> RainbowParenthesesLoadSquare
    au Syntax <buffer> RainbowParenthesesLoadBraces
  augroup END
endif
" }}}
" Javascript lint checker {{{
let g:syntastic_javascript_checkers = ['jshint', 'jscs']
"}}}
" Cleaning the file {{{
inoremap <silent> <buffer> <F4> <Esc>:call JavascriptBeautify()<CR>
nnoremap <silent> <buffer> <F4> :call JavascriptBeautify()<CR>
function! JavascriptBeautify() 
  let linenr=line('.')
  execute '%!jsclean %'
  execute 'normal '.linenr.'gg'
endfunction
" }}}

" $ù is easy to type on my keyboard. Use it for debug calls
inoremap <buffer> $ù console.log(

