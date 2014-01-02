" JAVASCRIPT;
" Use two spaces for indenting
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab
" Enable omnicomletion
setlocal omnifunc=javascriptcomplete#CompleteJS

" Enable rainbow parentheses
augroup rainbow_parentheses_javascript
	au!
	" au Syntax <buffer> syntax clear jsFuncBlock
	" au Syntax <buffer> RainbowParenthesesLoadRound
	" au Syntax <buffer> RainbowParenthesesLoadSquare
	" au Syntax <buffer> RainbowParenthesesLoadBraces
augroup END

" Enabling folding
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
" augroup folding_javascript
" 	au!
" 	" au Syntax <buffer> syntax clear jsFuncBlock
" 	au Syntax <buffer> syntax region foldBraces start=/{/ end=/}/ transparent fold keepend extend
" augroup END
" 
" $ù is easy to type on my keyboard. Use it for debug calls
inoremap <buffer> $ù console.log()<left>
" Tired of typing this
inoremap <buffer> eer expect(err).to.not.exist;
inoremap <buffer> trc trycatch(function() {<CR><CR>}, done);<Up>

" Clean the file
function! b:CleanFile()
	silent execute '%!js-beautify --jslint-happy --indent-with-tabs -'
endfunction

" Run the file
function! b:RunFile()
	silent execute '!phantomjs %'
	" TODO: Run in tmux
	redraw!
endfunction

