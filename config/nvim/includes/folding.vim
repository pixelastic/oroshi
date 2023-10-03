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

	let line = getline(v:foldstart)

	" We stop early if we don't even have room to add the symbol in the first slot
	if line[1] !=# ' '
		return line
	endif

	return displayedSymbol . line[byteidx(line, 1):-1]
endfunction
set foldtext=OroshiFoldText()
