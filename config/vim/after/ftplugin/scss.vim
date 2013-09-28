" SCSS
" Generate generates a css file from a scss file
function! b:RunFile()
	let output = expand('%:p:r') . '.css'
	execute '!sass --cache-location /tmp/.sass-cache --unix-newlines --style compact --scss -E utf-8 % ' . output
endfunction

" Generate css file from scss on save
augroup generate_css_from_scss
	au!
	au BufWritePre <buffer> silent call b:RunFile()
augroup END
