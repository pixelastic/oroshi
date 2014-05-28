" CTRLP
" Default options {{{
" Will search in repository, not MRU
let g:ctrlp_cmd = 'CtrlP'
" Show only 5 results
let g:ctrlp_max_height = 5
" Search by filepath and not just filename
let g:ctrlp_by_filename = 0
" Open found file after all tabs
let g:ctrlp_tabpage_position = 'al'
" Cache directory
let g:ctrlp_cache_dir = '~/.vim/cache/ctrlp'
" Keep cache when exiting vim, allowing for cache sharing between vim instances
let g:ctrlp_clear_cache_on_exit = 0
" Make it work in insert mode as well
inoremap <silent> <C-P> <Esc>:CtrlP<CR>
" }}}
" Mappings {{{
" Open in new tab as default <Enter> press, and edit in buffer with Ctrl-B
" Quit with Maj and Ctrl-D as well as default <Esc> and Ctrl-C
" Disable filepath/directory mode
let g:ctrlp_prompt_mappings = {
	\ 'AcceptSelection("t")': ['<cr>', '<c-t>'],
	\ 'AcceptSelection("e")': ['<c-b>'],
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
	let sl .= '%#oroshi_StatusLineModeCtrlP# CTRL-P %*'
	let sl .= '%#oroshi_StatusLineModeCtrlPArrow#⮀%*'
	" Separator
	let sl .= '%='
	" Current dir
	let sl .= getcwd()
	return sl
endfunction

" Progress status line
function! CtrlPStatusLineProg(...)
	let sl = ''
	" Mode
	let sl .= '%#oroshi_StatusLineModeCtrlP# CTRL-P %*'
	let sl .= '%#oroshi_StatusLineModeCtrlPArrow#⮀%*'
	" Status or length
	let sl .= ' '.a:1
	" Separator
	let sl .= '%='
	" Current dir
	let sl .= getcwd()
	return sl
endfunction
" }}}
