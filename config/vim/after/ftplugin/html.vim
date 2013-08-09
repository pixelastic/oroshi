" HTML

" Folding {{{
function! HTMLFoldTag()
	if foldclosed('.')==-1
		normal zfat
	else
		normal zo
	endif
endfunction
setlocal foldmethod=manual
nnoremap <buffer> za :call HTMLFoldTag()<CR>
" }}}
" Clean file {{{
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
" }}}
" Remove scripts from file {{{
function! b:RemoveScripts()
	let @z = 'gg/<scriptdat@z'
	silent normal @z
	" TODO: Find a cleaner way to not show the error message at the end of the
	" recursive macro.
	redraw!
endfunction
nnoremap <buffer> O1;5S :call b:RemoveScripts()<CR>
" }}}
" Run file {{{
function! b:RunFile()
	call OpenUrlInBrowser(expand('%:p'))
endfunction
" }}}

" Ctrl+C closes opened tags (using ragtags)
imap <C-c> <C-X>/<Esc>mzvat=`zi<Right>
" Ctrl+E expands zen-coding string (using sparkup)
imap <C-e> <C-Y>,

