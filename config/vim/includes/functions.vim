" Helpers
function! GetRepoRoot() " {{{
	" Use caching
	if exists('b:repoRoot')
		return b:repoRoot
	endif

	let workingDir = getcwd()

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
		let line = substitute(line, commentDelimiters[0] . '.*$', '', '')
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
function! ConvertTabsToSpaces() " {{{
	normal mz
	silent! execute '%s/^\t\+/\=repeat(" ", len(submatch(0))*'.&ts.')/'
	nohl
	normal `z
endfunction
command! ConvertTabsToSpaces call ConvertTabsToSpaces()
" }}}
function! ConvertSpacesToTabs() " {{{
	normal mz
	silent! execute '%s#\v^( {'.&ts.'})+#\=repeat("\t", len(submatch(0))/'.&ts.')'
	nohl
	normal `z
endfunction
command! ConvertSpacesToTabs call ConvertSpacesToTabs()
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
