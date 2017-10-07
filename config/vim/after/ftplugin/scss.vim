" Linting {{{
let b:syntastic_checkers = ['stylelint']
" }}}
" Misc {{{
" Remove - and _ from delimiters
setlocal iskeyword=@,48-57,192-255
" }}}
" Indentation rules {{{
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab
" }}}
" Folding {{{
setlocal foldmethod=syntax
" }}}
" Keybindings {{{
nnoremap ss viB:sort<CR>
" }}}
" Cleaning the file {{{
nnoremap <silent> <buffer> <F4> :call ScssClean()<CR>
function! ScssClean() 
  normal mz
  " Add space after colon
  silent! %s/:\(\S\)/: \1/
  " Fix previous replace...
  silent! %s/: \(checked\|hover\|active\|focus\|before\|after\)/:\1/
  " Add space after comma
  silent! %s/,\(\S\)/, \1/
  " Convert /* */ comments to //
  silent! %s_/\*\(.*\)\*/_//\1_
  " Convert double quotes to single quotes
  silent! %s/"/'/
  " Remove leading zero in units
  silent! %s/ 0\.\([0-9]\)/ .\1/
  " Remove dangling _ from @import
  silent! %s/@import '_/@import '/
  " Add lines between selectors
  silent! %s/}\n\./}\r\r./
  normal `z
	call RemoveTrailingSpaces()
endfunction
" }}}
