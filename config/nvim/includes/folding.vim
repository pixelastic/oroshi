" FOLDING
" Start with a few folds open to have the structure overview
set foldlevel=3

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

" [za] Opening/closing all folds
function! FoldToggle()
	if foldclosed('.')==-1
		silent! normal zc
	else
		normal zO
	endif
endfunction
nnoremap <silent> za :call FoldToggle()<CR>

" Custom foldtext
function! OroshiFoldText(...)
	let displayedSymbol = ''
	let displayedLineCount = ' ' . (v:foldend - v:foldstart) . ' '

	let line = getline(v:foldstart)

	" We stop early if we don't even have room to add the symbol in the first slot
	if line[1] !=# ' '
		return line
	endif

	" We check if we can add the number of lines
	let hasLineCount=0
	let displayedLineCountLength = StrLength(displayedLineCount)
	let lineCountInsertRangeStart = byteidx(line, 1)
	let lineCountInsertRangeEnd = byteidx(line, displayedLineCountLength)
	let cookieCutter = line[lineCountInsertRangeStart:lineCountInsertRangeEnd]
	let emptyString = repeat(' ', displayedLineCountLength)
	if cookieCutter == emptyString
		let hasLineCount=1
	endif

	let foldtext = displayedSymbol
	if hasLineCount == 1
		let foldtext .= displayedLineCount
	else
		let foldtext .= cookieCutter
	endif

	let foldtext .= line[lineCountInsertRangeEnd + 1:-1]

	return foldtext
endfunction
set foldtext=OroshiFoldText()
