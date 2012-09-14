" JAVASCRIPT
" $ù is easy to type on my keyboard. Use it for debug calls
inoremap <buffer> $ù console.log()<left>
" Clean the file to make it prettier
nnoremap <buffer> <F4> :silent %!jsbeautify -j -t -<CR>
" Run the current file in phantomjs
nnoremap <buffer> <F5> :!phantomjs %<CR>
