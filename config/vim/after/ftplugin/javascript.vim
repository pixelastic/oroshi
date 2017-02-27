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
let b:repo_root = GetRepoRoot()
let b:eslint_enabled = 0
let b:jscs_enabled = 0
" Check which linters are currently enabled
if filereadable(b:repo_root . '/.eslintrc')
  let b:eslint_config = b:repo_root . '/.eslintrc'
endif
if filereadable(b:repo_root . '/.eslintrc.js')
  let b:eslint_config = b:repo_root . '/.eslintrc.js'
endif
if exists('b:eslint_config')
  let b:eslint_enabled = 1
  let b:eslint_bin = StrTrim(system('npm-which eslint'))
endif
if filereadable(b:repo_root . '/.jscsrc')
  let b:jscs_enabled = 1
  let b:jscs_bin = StrTrim(system('npm-which jscs'))
endif
" Adding matching linters to syntastic
let b:syntastic_checkers = []
if b:eslint_enabled
  let b:syntastic_javascript_eslint_exec = b:eslint_bin
  let b:syntastic_checkers = b:syntastic_checkers + ['eslint']
endif
if b:jscs_enabled
  let b:syntastic_javascript_jscs_exec = b:jscs_bin
  let b:syntastic_checkers = b:syntastic_checkers + ['jscs']
endif
" Default to system-wide eslint if nothing configured
if len(b:syntastic_checkers) == 0
  let b:syntastic_checkers = b:syntastic_checkers + ['eslint']
endif
"}}}
" Cleaning the file on F4 {{{
nnoremap <silent> <F4> :call JavaScriptClean()<CR>
inoremap <silent> <F4> <Esc>:call JavaScriptClean()<CR>li
" }}}
function! JavaScriptClean() 
  " We save the current line, to be able to jump to it later
  let linenr=line('.')

  let tmp_file = fnameescape(tempname().'.js')
  let content = getline('1', '$')

  " Save current content in a temporary file
  call writefile(content, tmp_file)
  " Apply eslint --fix on it
  let command = b:eslint_bin.' -c '.b:eslint_config.' --fix '.tmp_file
  call system(command)

  " Read result and apply it to the current file
  let result = readfile(tmp_file)
  silent exec "1,$j"
  call setline("1", result[0])
  call append("1", result[1:])

  execute 'normal '.linenr.'gg'
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
" ES6 {{{
" Enable JSX syntax highlight in javascript files
let g:jsx_ext_required = 0
" }}}
