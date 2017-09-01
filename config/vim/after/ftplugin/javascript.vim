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
" ESLint {{{
let b:syntastic_checkers = ['eslint']
let b:syntastic_javascript_eslint_exec = StrTrim(system('npm-which eslint'))
" }}}
" Prettier {{{
" Reformat the file on F4...
nnoremap <silent> <F4> :Neoformat<CR>
inoremap <silent> <F4> <Esc>:Neoformat<CR>li
" " ...but also on each save if Prettier is defined in this repo
let b:prettier_bin = 'prettier'
" let b:prettier_raw_local_check = system('npm-is-local prettier')
" let b:prettier_is_local = (v:shell_error == '0')
"
" if b:prettier_is_local
"   let b:prettier_bin = StrTrim(system('npm-which prettier'))
"   augroup javascript_prettier_format
"     autocmd!
"     autocmd BufWritePre <buffer> Neoformat
"   augroup END
" endif

let g:neoformat_only_msg_on_error = 1
let b:neoformat_enabled_javascript = ['prettier']
let b:neoformat_javascript_prettier = {
  \ 'exe': b:prettier_bin,
  \ 'args': ['--single-quote', '--trailing-comma es5'],
  \ 'stdin': 1,
  \ }



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
