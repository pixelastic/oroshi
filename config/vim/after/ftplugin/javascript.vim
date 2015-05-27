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
" Linters {{{
let b:repo_root = GetRepoRoot()
let b:syntastic_checkers = []
" Use only linters defined in the repo
if filereadable(b:repo_root . '/.eslintrc')
  let b:syntastic_checkers = b:syntastic_checkers + ['eslint']
endif
if filereadable(b:repo_root . '/.jshintrc')
  let b:syntastic_checkers = b:syntastic_checkers + ['jshint']
endif
if filereadable(b:repo_root . '/.jscsrc')
  let b:syntastic_checkers = b:syntastic_checkers + ['jscs']
endif
" Default to system-wide eslint if nothing configured
if len(b:syntastic_checkers) == 0
  let b:syntastic_checkers = b:syntastic_checkers + ['eslint']
endif
"}}}
" Cleaning the file {{{
inoremap <silent> <buffer> <F4> <Esc>:call JavascriptBeautify()<CR>
nnoremap <silent> <buffer> <F4> :call JavascriptBeautify()<CR>
function! JavascriptBeautify() 
  let linenr=line('.')
  silent! execute ':%s/^\s*$//'
  " " Remove empty lines after function definitions
  " silent! execute '%s/{\n\n/{\r/'
  " " clean the file
  " silent! w! /tmp/vim_jsclean
  " silent! execute '%!jsclean /tmp/vim_jsclean'
  execute 'normal '.linenr.'gg'
endfunction
" }}}
" Keybindings {{{
" $ù is easy to type on my keyboard. Use it for debug calls
inoremap <buffer> $ù console.log(
" }}}

