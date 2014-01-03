" FOLDING
" Do not auto-fold code by default
set foldlevel=0
" Short aliases to fold to predefined depth
nnoremap <silent> z& :setlocal foldlevel=1<CR>
nnoremap <silent> zé :setlocal foldlevel=2<CR>
nnoremap <silent> z" :setlocal foldlevel=3<CR>
nnoremap <silent> z' :setlocal foldlevel=4<CR>
nnoremap <silent> z( :setlocal foldlevel=5<CR>
nnoremap <silent> z- :setlocal foldlevel=6<CR>
nnoremap <silent> zè :setlocal foldlevel=7<CR>
nnoremap <silent> z_ :setlocal foldlevel=8<CR>
nnoremap <silent> zç :setlocal foldlevel=9<CR>
nnoremap <silent> zà :setlocal foldlevel=0<CR>
" Custom foldtext
set foldtext=OroshiFoldText()
function! OroshiFoldText(...)
	" Add indentation and title
	let textleft = repeat(' ', indent(v:foldstart))
	let textleft .= (a:0 == 1 ) ? a:1 : StrUncomment(getline(v:foldstart))
	let textleft_width = StrLength(textleft)

	" Number of lines in the fold
	let textright = '   ' . (v:foldend - v:foldstart) . ' }}}'
	let textright_width = StrLength(textright)

	" Window width
	let window_width = winwidth(0) - &foldcolumn - (&number ? &numberwidth : 0)

	" If line is too long, we crop the end
	if textleft_width + textright_width >= window_width
		let final_text = strpart(textleft, 0, window_width - textright_width) . textright
	else
		let padding = repeat(' ', window_width - textleft_width - textright_width)
		let final_text = textleft . padding . textright
	endif

	return final_text
endfunction
