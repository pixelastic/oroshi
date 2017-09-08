" VUE
" Linting {{{
let b:eslint_bin = StrTrim(system('npm-which eslint'))
let b:syntastic_checkers = ['pug_lint_vue', 'eslint']
let b:syntastic_vue_eslint_exec = b:eslint_bin
" }}}
" Cleaning {{{
inoremap <silent> <buffer> <F4> <Esc>:call VueBeautify()<CR><CR>
nnoremap <silent> <buffer> <F4> :call VueBeautify()<CR><CR>
function! VueBeautify() 
  " We'll use eslint --fix to reformat the file. ESLint is the defacto linter,
  " with a huge list of plugins, including some for Vue.js and prettier. It also
  " comes with a --fix option that will use all those plugins. It is a better
  " solution than piping several tools in terms of maintainance.
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
  let eslintCommand = b:eslint_bin.' '.l:tempFile.' --ext .js,.vue --fix'
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
" }}
