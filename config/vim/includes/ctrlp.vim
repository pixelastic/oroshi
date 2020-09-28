" CTRLP
" Default options {{{
" Will search in repository, not MRU
let g:ctrlp_cmd = 'CtrlP'
" Show only 5 results
let g:ctrlp_max_height = 5
" Results are display at the bottom of the screen
let g:ctrlp_match_window_bottom = 1
let g:ctrlp_match_window_reversed = 0
" Search by filepath and not just filename
let g:ctrlp_by_filename = 0
" Open found file after all tabs
let g:ctrlp_tabpage_position = 'al'
" Do not use cache at all
let g:ctrlp_use_caching = 0
" Make it work in insert mode as well
inoremap <silent> <C-P> <Esc>:CtrlP<CR>
" }}}
" Mappings {{{
" Open in new tab as default <Enter> press
" Quit with Maj and Ctrl-D as well as default <Esc> and Ctrl-C
" Disable filepath/directory mode
let g:ctrlp_prompt_mappings = {
	\ 'AcceptSelection("t")': ['<cr>'],
	\ 'AcceptSelection("e")': [],
	\
	\ 'PrtExit()':            ['<esc>', '<c-c>', '<c-d>', '[25~'],
  \ 'ToggleByFname()':      [],
	\ 'ToggleType(1)':        [],
	\ 'ToggleType(-1)':       [],
\ }
" }}}
" Search commands {{{
let g:ctrlp_user_command = {
	\ 'types': {
		\ 1: ['.git', '~/.vim/includes/scripts/ctrlp_git %s']
		\ },
	\ 'ignore': 0
	\ }
" }}}
" Status line {{{
let g:ctrlp_status_func = {
	\ 'main': 'CtrlPStatusLineMain',
	\ 'prog': 'CtrlPStatusLineProg',
	\ }
" Main status line
function! CtrlPStatusLineMain(...)
	let sl = ''
	" Mode
	let sl .= '%#StatusLineModeCtrlP# CTRL-P %*'
	let sl .= '%#StatusLineModeCtrlPSeparator#⮀%*'
	" Separator
	let sl .= '%='
	" Current dir
	let sl .= fnamemodify(GetRepoRoot(), ':t')
	return sl
endfunction

" Progress status line
function! CtrlPStatusLineProg(...)
	let sl = ''
	" Mode
	let sl .= '%#StatusLineModeCtrlP# CTRL-P %*'
	let sl .= '%#StatusLineModeCtrlPSeparator#⮀%*'
	" Status or length
	let sl .= ' '.a:1
	" Separator
	let sl .= '%='
	" Current dir
	let sl .= fnamemodify(GetRepoRoot(), ':t')
	return sl
endfunction
" }}}
