" SCSS
" Generate generates a css file from a scss file
function! b:RunFile()
	let output = expand('%:p:r') . '.css'
	silent execute '!sass --cache-location /tmp/.sass-cache --unix-newlines --style compact --scss -E utf-8 % ' . output 
endfunction
