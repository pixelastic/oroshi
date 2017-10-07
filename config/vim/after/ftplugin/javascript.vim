" JAVASCRIPT
" Misc {{{
" Indentation rules
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab
setlocal equalprg=eslint_d\ --stdin\ --fix-to-stdout\ -
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
" Linting {{{
let b:syntastic_checkers = ['eslint']
let b:syntastic_javascript_eslint_exec = 'eslint_d'
" }}}
" Cleaning {{{
inoremap <silent> <buffer> <F4> <Esc>:call JavascriptBeautify()<CR><CR>
nnoremap <silent> <buffer> <F4> :call JavascriptBeautify()<CR><CR>
function! JavascriptBeautify() 
  let l:initialLine = line('.')
  execute '%!eslint_d --stdin --fix-to-stdout'
  execute 'normal '.initialLine.'gg'
  SyntasticCheck()
endfunction
" }}}

" Keybindings {{{
" $ù is easy to type on my keyboard. Use it for debug calls
inoremap <buffer> $ù console.info(
" Using ## (as in ruby) for string interpolation
inoremap <buffer> ## ${}<Left>
" context, beforeEach and it
inoremap <buffer> bfe beforeEach(() => {});ko
inoremap <buffer> iit it('', () => {<CR>// Given<CR>When<CR>Then<CR><Esc>Vc<BS>});4k2li
inoremap <buffer> cnt context('', () => {});kllllllli
inoremap <buffer> dsc describe('', () => {});klllllllli
" }}}
