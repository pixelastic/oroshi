" JSON
" Indentation rules {{{
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab
setlocal equalprg=js-beautify\ -f\ -
" }}}
" Cleaning the file {{{
nnoremap <silent> <buffer> <F4> :call JavascriptBeautify()<CR>
function! JavascriptBeautify() 
	let linenr=line('.')
	execute '%!js-beautify -f -'
	call RemoveTrailingSpaces()
	execute 'normal '.linenr.'gg'
endfunction
" }}}
" Use javascript syntax highlighting
au BufEnter <buffer> setlocal syntax=javascript

