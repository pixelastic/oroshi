" HTML
" Add manual folding around tags
function! HTMLFoldTag()
	if foldclosed('.')==-1
		normal zfat
	else
		normal zo
	endif
endfunction
setlocal foldmethod=manual
nnoremap <buffer> za :call HTMLFoldTag()<CR>

" Clean the file
function! b:CleanFile()
	let tidyrc="~/.tidyrc"
	let tidyCommand="silent %!tidy"

	" Use custom config if found
	if !filereadable(tidyrc)
		let tidyCommand = tidyCommand." -config ".tidyrc
	endif
	execute tidyCommand

	" Tidy indents everything with spaces, we convert to tabs
	silent call IndentWithTabs()
endfunction

" Run the file
function! b:RunFile()
	silent !gui chromium-browser %
	redraw!
endfunction

" Remove scripts from file
function! b:RemoveScripts()
	let @z = 'gg/<scriptdat@z'
	silent normal @z
	redraw!
endfunction
nnoremap <buffer> O1;5S :call b:RemoveScripts()<CR>
