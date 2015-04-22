" Ctrl-F
" Used to find a string in the current project
nnoremap <C-F> :FindInProject 
command! -nargs=1 FindInProject call FindInProject(<q-args>)
" Defining ag for grep
let &grepprg = 'ag'
" FindInProject() {{{
function! FindInProject(txt)
	" We expose those two values globally to be able to display them in the
	" statusline
	let g:CtrlFRepoRoot = GetRepoRoot()
	let g:CtrlFSearchPattern = a:txt

	" We execute the search, but immediatly switch back to the initial buffer as
	" the default grep command switches the current buffer to the first match
	let currentBuffer = bufnr('%')
	mkview!
	silent execute 'grep ' . a:txt .' ' . g:CtrlFRepoRoot
	execute 'buffer '.currentBuffer
	loadview
        
  " Then, we open the quicksearch window
  copen

	redraw!

	" Set a custom statusline
	setlocal statusline=%!FindInProjectStatusLine()
endfunction
" }}}
" FindInProjectStatusLine() {{{
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
