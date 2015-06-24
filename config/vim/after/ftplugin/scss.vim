" Syntastic {{{
let g:syntastic_scss_checkers = ['sassc', 'scss_lint']
if !exists('g:syntastic_scss_scss_lint_args') || g:syntastic_scss_scss_lint_args==''
	let g:syntastic_scss_scss_lint_args = '--config ~/.scss-lint.yml'
endif
"}}}
" Cleaning the file {{{
nnoremap <silent> <buffer> <F4> :call ScssClean()<CR>
function! ScssClean() 
  normal mz
  " Add space after colon
  silent! %s/:\(\S\)/: \1/
  " Fix previous replace...
  silent! %s/: \(checked\|hover\|active\|focus\|before\|after\)/:\1/
  " Convert /* */ comments to //
  silent! %s_/\*\(.*\)\*/_//\1_
  " Convert double quotes to single quotes
  silent! %s/"/'/
  " Remove leading zero in units
  silent! %s/ 0\.\([0-9]\)/ .\1/
  normal `z
	call RemoveTrailingSpaces()
endfunction
" }}}

