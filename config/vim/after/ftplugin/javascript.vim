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
" Linting {{{
let b:eslint_bin = StrTrim(system('npm-which eslint'))
let b:syntastic_checkers = ['eslint']
let b:syntastic_javascript_eslint_exec = b:eslint_bin
" }}}
" Cleaning {{{
inoremap <silent> <buffer> <F4> <Esc>:call JavascriptBeautify()<CR><CR>
nnoremap <silent> <buffer> <F4> :call JavascriptBeautify()<CR><CR>
function! JavascriptBeautify() 
  " We'll use eslint --fix to reformat the file. ESLint is the defacto linter,
  " with a huge list of plugins, including one for prettier. It also comes with
  " a --fix option that will use all those plugins. It is a better solution than
  " piping several tools in terms of maintainance.
  "
  " The downside is that eslint --fix will update the file in place, not
  " outputing the new version. It means we'll have to have it operate on a copy
  " of our original file, and then (only if no errors happened), replace the
  " original content with the updated one.

  " It can take some time, so adding an indicator
  echom 'Fixing file...'
  let l:initialLine = line('.')

  " Filepath information about our file
  let l:currentFile = shellescape(expand('%:p'))
  let l:dirname = fnamemodify(l:currentFile, ':h')
  let l:filename = fnamemodify(l:currentFile, ':t')
  let l:basename = fnamemodify(l:currentFile, ':t:r')
  let l:extname = fnamemodify(l:currentFile, ':e')

  " Creating a copy of the file in the same dir (so imports works correctly)
  let l:tempPattern = l:dirname.'/'.l:basename.'.XXXXXX.'.l:extname
  let l:tempFile = StrTrim(system('mktemp '.l:tempPattern))
  let l:content = getline('1', '$')
 	call writefile(l:content, l:tempFile)

  " Fixing the copied file
  let eslintCommand = b:eslint_bin.' '.l:tempFile.' --fix'
  call system(eslintCommand)
  let eslintStatus = v:shell_error

  " Replacing the content of the file
  execute '%!cat '.l:tempFile
  write

  " Cleaning up everything we did
  call delete(l:tempFile)
  echom 'File fixed!'
  execute 'normal '.initialLine.'gg'
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
