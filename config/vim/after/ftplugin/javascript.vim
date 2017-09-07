" JAVASCRIPT
" Misc {{{
" Indentation rules
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab
setlocal equalprg=js-beautify\ -f\ -
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
" Linters {{{
" ESLint {{{
let b:eslint_bin = StrTrim(system('npm-which eslint'))
let b:syntastic_checkers = ['eslint']
let b:syntastic_javascript_eslint_exec = b:eslint_bin
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
" ES6 {{{
" Enable JSX syntax highlight in javascript files
let g:jsx_ext_required = 0
" }}}
