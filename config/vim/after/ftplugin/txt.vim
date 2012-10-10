" TXT
" Force txt to fit in 79 columns
setlocal formatoptions+=t
" Allow folding with marker
setlocal foldmethod=marker
setlocal commentstring=\ %s
" Make txt files more portable
if expand('%:e') == 'txt'
	silent call ConvertLineEndingsToUnix()
	silent call ConvertWindowsCharacters()
endif

" I often need to tweak epub files, so I convert them to txt and manually edit
" them. This will help in doing most of the work
function! FixEpub()
	normal mz
	" [...] MOON.GLORIOUS moon,the night [...]
	silent! %s/\v(\.|,)(\S)/\1 \2/
	" [...] Orphanage inHomestead, [...]
	silent! %s/\v(\l)(\u)/\1 \2/
	" [...] WOULD NOThave been [...]
	silent! %s/\v(\u{2})(\l)/\1 \2/
	" I T IS ALWAYS A BAD IDEA [...]
	" silent! %s/\v^(\u) (\u)/\1\2/
	
	" — Ce Rochefort, [...]
	" 
	" Chalais, passerait avec moi un vilain moment.
	silent! %s/\v^— ((.*)[^\.!\?])\n\n([^—](.*))$/— \1 \3/
	" — Ce Rochefort, [...]
	" 
	" 
	" 
	" — Et vous, [...]
	silent!	%s/\v^(— (.*))\n{3,}(— (.*))/\1\r\r\3/
	silent!	%s/\v^(— (.*))\n{3,}(— (.*))/\1\r\r\3/

	
	
	" sentence cut in half with new lines
	silent! %s/\v(\l)(\n)+(\l)/\1 \3/

	


	nohl
	normal `z
endfunction
