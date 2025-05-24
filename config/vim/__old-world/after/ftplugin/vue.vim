" VUE


" Linting {{{
let b:eslint_bin = StrTrim(system('npm-which eslint'))
" }}}
" Cleaning {{{
inoremap <silent> <buffer> <F4> <Esc>:call VueBeautify()<CR><CR>
nnoremap <silent> <buffer> <F4> :call VueBeautify()<CR><CR>
function! VueBeautify()
  " Note: It seems that eslint_d cannot fix .vue files, so we have to manually
  " copy the file, run eslint --fix on it, and re-apply the file content to the
  " current buffer
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

  " Cleaning up everything we did
  call delete(l:tempFile)
  echom 'File fixed!'
  execute 'normal '.initialLine.'gg'

  " As this can mess the syntax highlight, we force it back
  syntax sync fromstart
endfunction
" }}}
" Keybindings {{{
" $ù is easy to type on my keyboard. Use it for debug calls
inoremap <buffer> $ù console.info(
" Using ## (as in ruby) for string interpolation
inoremap <buffer> ## ${}<Left>
" }}
" Syntax Highlighting {{{
syntax sync fromstart
" }}}
