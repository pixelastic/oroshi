" JAVASCRIPT;
" $ù is easy to type on my keyboard. Use it for debug calls
inoremap <buffer> $ù console.log()<left>
" Enable omnicomletion
setlocal omnifunc=javascriptcomplete#CompleteJS
" Use two spaces for indenting
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab

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

