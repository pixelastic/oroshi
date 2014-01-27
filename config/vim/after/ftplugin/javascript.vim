" JAVASCRIPT
" Indentation rules {{{
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab
setlocal equalprg=js-beautify\ -f\ -
" }}}
" TernJS {{{
nnoremap <buffer> rr :TernRename<CR>
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
" Cleaning the file {{{
nnoremap <silent> <buffer> <F4> :call JavascriptBeautify()<CR>
function! JavascriptBeautify() 
	let linenr=line('.')
	execute '%!js-beautify -f -'
	call RemoveTrailingSpaces()
	execute 'normal '.linenr.'gg'
endfunction
" }}}

" $ù is easy to type on my keyboard. Use it for debug calls
inoremap <buffer> $ù console.log(

