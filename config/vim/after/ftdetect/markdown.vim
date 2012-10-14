" MARKDOWN
" Note: txt files extracted from ebooks should be interpreted as markdown as
" formatting will be kept when converted to epub
au BufRead,BufNewFile *.txt call SetAsMarkdownIfFromEbook()
function! SetAsMarkdownIfFromEbook()
	if filereadable(expand("%:p:r").".epub")
		setlocal filetype=markdown
	endif
endfunction
