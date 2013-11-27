" JAVASCRIPT;
" $ù is easy to type on my keyboard. Use it for debug calls
inoremap <buffer> $ù console.log()<left>
" Tired of typing this
inoremap <buffer> eer expect(err).to.not.exist;
inoremap <buffer> trc trycatch(function() {<CR><CR>}, done);<Up>
" Enable omnicomletion
setlocal omnifunc=javascriptcomplete#CompleteJS
" Use two spaces for indenting
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab
" Enabling folding
" Note: see .vimrc for the method that actually enable folding
setlocal foldmethod=syntax
setlocal foldlevelstart=99
setlocal foldtext=JavascriptFoldText()
function! JavascriptFoldText()
	return substitute(getline(v:foldstart), '{.*', '{...}', '')
endfunction

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

