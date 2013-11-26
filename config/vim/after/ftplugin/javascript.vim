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
" Enabling folding
setlocal foldmethod=syntax
setlocal foldlevel=99
" Note: Because of the order in which vim files are loaded, we need to resort
" to the `au BufEnter <buffer>` trick to apply the method after the plugins. It
" will clean the fold regexp defined by vim-javascript and apply our own
" instead (actually taken from vim-javascript-syntax).
au BufEnter <buffer> call JavascriptEnableFolding()
function! JavascriptEnableFolding()
	syntax clear jsFuncBlock
	syn region foldBraces start=/{/ end=/}/ transparent fold keepend extend
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

