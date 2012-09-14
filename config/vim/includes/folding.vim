" FOLDING
" Do not auto-fold code
set foldlevel=0
" Custom foldtext
set foldtext=OroshiFoldText()
function! OroshiFoldText(...)
	let textleft = '{{{ '

	" Add indentation
	let textleft .= repeat(' ', indent(v:foldstart))
	
	" Add title
	let textleft .= (a:0 == 1 ) ? a:1 : StrUncomment(getline(v:foldstart))

	" Number of lines in the fold
	let textright = (v:foldend - v:foldstart) . ' lines }}}'

	" Padding between the left and right parts. Making sure it neatly fit on
	" screen.
	let width = winwidth(0) - &foldcolumn - (&number ? &numberwidth : 0)
	if &textwidth < width
		let width = &textwidth + 1
	endif
	let padding = repeat(' ', width - len(textleft) - len(textright))

	return textleft.padding.textright
endfunction
