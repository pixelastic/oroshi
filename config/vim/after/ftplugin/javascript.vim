" JAVASCRIPT
" $ù is easy to type on my keyboard. Use it for debug calls
inoremap <buffer> $ù console.log()<left>
" Enable omnicomletion
setlocal omnifunc=javascriptcomplete#CompleteJS

" Clean the file
function! b:CleanFile()
	silent execute '%!js-beautify -j -t -'
endfunction

" Run the file
function! b:RunFile()
	silent execute '!phantomjs %'
	" TODO: Run in tmux
	redraw!
endfunction

