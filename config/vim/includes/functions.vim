" Helpers
function! GetRepoRoot() " {{{
	" Use caching
	if exists('b:repoRoot')
		return b:repoRoot
	endif

	let workingDir = expand('%:h')

	" Check if git
	let gitRoot = system('cd '.workingDir.' && git rev-parse --show-toplevel')
	if gitRoot !~ '^fatal'
		let b:repoRoot = StrTrim(gitRoot)
		return b:repoRoot
	endif

	" Check if Mercurial
	let hgRoot = system('cd '.workingDir.' && hg root')
	if hgRoot !~ '^abort'
		let b:repoRoot = StrTrim(hgRoot)
		return b:repoRoot
	endif

	let b:repoRoot = workingDir
	return b:repoRoot
endfunction
" }}}
function! Debug(txt) " {{{
	" Display a var in the status line, for debug purposes
	let b:o_debug = a:txt
endfunction
command! -nargs=1 Debug call Debug(<q-args>)
" }}}
function! GDebug(txt) " {{{
	" Display a var in the status line, for debug purposes
	let g:o_debug = a:txt
endfunction
command! -nargs=1 GDebug call GDebug(<q-args>)
" }}}

" String methods
function! StrTrim(txt) " {{{
	" Trim a string by removing starting and trailing whitespaces
	return substitute(a:txt, '^\n*\s*\(.\{-}\)\n*\s*$', '\1', '')
endfunction
" }}}
function! StrUncomment(txt) " {{{
	" Removes all comment and fold marker of a string
	let line = a:txt

	" Remove comments
	let commentDelimiters = split(&commentstring, '%s')
	let line = substitute(line, '^\s*' . StrTrim(commentDelimiters[0]), '', '')
	if len(commentDelimiters) > 1
		let line = substitute(line, commentDelimiters[1] . '$', '', '')
	endif

	" Remove folding marker
	if (&foldmethod == 'marker')
		let foldmarkerDelimiters = split(&foldmarker, ',')
		let line = substitute(line, foldmarkerDelimiters[0] . '.*$', '', '')
		" Remove trailing comment used to add the previously deleted foldmarker
		if strlen(StrTrim(commentDelimiters[0])) > 1
			let line = substitute(line, commentDelimiters[0] . '.*$', '', '')
		endif
	endif

	" Trim title
	let line = StrTrim(line)

	return line
endfunction
"}}}

" Commands
function! RemoveTrailingSpaces() " {{{
	normal mz
	silent! %s/\s\+$//g
	nohl
	normal `z
endfunction
command! RemoveTrailingSpaces call RemoveTrailingSpaces()
" }}}
function! IndentWithSpaces() " {{{
	normal mz
	" Replace all tabs used for indentation with the same number of spaces
	silent! execute '%s/\v^\s+/\=substitute(submatch(0),"\t",repeat(" ", &tabstop),"g")'
	" Remove any leftover
	silent! execute '%s/\v^ +/\=repeat(" ",len(submatch(0))-(len(submatch(0))%&tabstop))'
	nohl
	normal `z
endfunction
command! IndentWithSpaces call IndentWithSpaces()
" }}}
function! IndentWithTabs() " {{{
	normal mz
	" Indent first with spaces, then convert to tabs
	silent! call IndentWithSpaces()
	silent! execute '%s_\v^ +_\=repeat("\t",len(submatch(0))/&tabstop)'
	nohl
	normal `z
endfunction
command! IndentWithTabs call IndentWithTabs()
" }}}
function! ConvertLineEndingsToUnix() " {{{
	if &modifiable==0 || expand('%') == '' || !filereadable(expand('%'))
		return
	endif
	update
	edit ++fileformat=dos
	setlocal fileformat=unix
	write
endfunction
command! ConvertLineEndingsToUnix call ConvertLineEndingsToUnix()
" }}}
function! ConvertLineEndingsToDos() " {{{
	if &modifiable==0
		return
	endif
	setlocal fileformat=dos
endfunction
command! ConvertLineEndingsToDos call ConvertLineEndingsToDos()
" }}}
function! ConvertWindowsCharacters() " {{{
	" Note: To type a special char like <92> in vim, press <C-V>x92
	normal mz
	silent! %s//'/
	silent! %s//"/
	silent! %s//"/
	silent! %s//.../
	nohl
	normal `z
endfunction
command! ConvertWindowsCharacters call ConvertWindowsCharacters()
" }}}
function! ConvertToUTF8() " {{{
	set fileencoding=utf-8
endfunction
command! ConvertToUTF8 call ConvertToUTF8()
" }}}
function! FixEpub() " {{{
	" I often need to tweak epub files, so I convert them to txt and manually edit
	" them. This will help in doing most of the work
	
	normal mz
	" [...] MOON.GLORIOUS moon,the night [...]
	silent! %s/\v(\.|,)(\S)/\1 \2/
	" [...] Orphanage inHomestead, [...]
	silent! %s/\v(\l)(\u)/\1 \2/
	" [...] WOULD NOThave been [...]
	silent! %s/\v(\u{2})(\l)/\1 \2/
	" I T IS ALWAYS A BAD IDEA [...]
	" silent! %s/\v^(\u) (\u)/\1\2/
	
	" Dialogs should use the em dash (–) and not the simple dash (-)
	silent! %s/\v^-/–/
	
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
	
	" Punctuation signs lost on new lines
	silent! %s/\v\n\n(\?|!|;|»)/ \1/
	" French guillemets breaking sentences in new lines
	silent! %s/\v»\n\n(\U)/» \1/

	" Setting the first line as the main title
	if getline(1) !~ '^\#'
		execute 'normal ggI# '
	endif
	" Marking each heading as a chapter
	silent! %s/\v^([^#]{2}\L+)$/## \1/
	


	nohl
	normal `z
endfunction " }}}

function! OpenUrlInBrowser(url) " {{{
	" No url given
	if a:url==""
		return 0
	endif
	" Opening in chromium and redrawing vim screen
	exec ':silent !gui chromium-browser '.a:url
	redraw!
endfunction
command! -nargs=1 OpenUrlInBrowser call OpenUrlInBrowser(<q-args>)
" }}}
function! GetUrlUnderCursor() " {{{
	return escape(matchstr(getline("."),"http[^ [\\]()]*"), "#?&;|%")
endfunction
command! GetUrlUnderCursor call GetUrlUnderCursor()
" }}}
