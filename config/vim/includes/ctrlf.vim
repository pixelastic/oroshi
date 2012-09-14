" Ctrl-F
" TODO: Do not display full path but only path relative to the repo root
" Use ack instead of grep {{{
let &grepprg = 'ack-grep'
let &grepprg .= ' --noenv'
let &grepprg .= ' --with-filename'
let &grepprg .= ' --nocolor'
let &grepprg .= ' --nogroup'
let &grepprg .= ' --column'
let &grepprg .= ' --smart-case'
let &grepprg .= ' --sort-files'
let &grepprg .= ' --type-set txt=.txt'
let &grepprg .= ' --type-set config=.conf,.config,.ini'
let &grepprg .= ' --type-set markdown=.markdown,.mdown,.mkd,.mkdown,.md'
" }}}
" Ctrl-F to find in project {{{
nnoremap <C-F> :FindInProject 
command! -nargs=1 FindInProject call FindInProject(<q-args>)
function! FindInProject(txt)
	" Note: We expose those two values in the buffer because they will be needed
	" in the statusline
	let g:CtrlFRepoRoot = GetRepoRoot()
	let g:CtrlFSearchPattern = a:txt

	" Note: We go back to the current buffer as soon as the search ends
	" Note: We start the search in the current repository root
	let currentBuffer = bufnr('%')
	silent execute 'grep ' . a:txt .' ' . g:CtrlFRepoRoot
	execute 'buffer '.currentBuffer
	redraw!

	" We display the results in the quickfix window
	" Note: Custom keybindings are defined in ftplugin/qf.vim
	copen

	" Set a custom statusline
	setlocal statusline=%!FindInProjectStatusLine()
endfunction
" }}}
" Custom statusline {{{
function! FindInProjectStatusLine() 
	let sl = ''
	" Mode
	let sl .= '%#oroshi_StatusLineModeCtrlF# CTRL-F %*'
	let sl .= '%#oroshi_StatusLineModeCtrlFArrow#⮀%*'
	" Pattern
	let sl .= ' '.g:CtrlFSearchPattern
	" Separator
	let sl .= '%='
	" Repo dir
	let sl .= g:CtrlFRepoRoot
	return sl
endfunction
" }}}
