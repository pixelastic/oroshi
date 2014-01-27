" QUICK FIX / LOCATION LIST
" QuickfixClose() {{{
if !exists('*QuickfixClose')
	function! QuickfixClose()
		if &ft != "qf"
			return ""
		endif
		cclose
		lclose
	endfunction
endif
" }}}
" QuickfixType() {{{
if !exists('*QuickfixType')
	function! QuickfixType()

		" Note: Only way to tell between a quickfix and loclist is to try opening
		" a loclist and see if window number changes
		copen
		let winnr_after=winnr()
	endfunction
endif
" }}}

" Ctrl-D closes quickfix window
nnoremap <silent> <buffer> <C-D> :call QuickfixClose()<CR>
" Enter : open result in new tab, go to tab and close results
nnoremap <silent> <buffer> <CR> <C-W><CR><C-W>TgT:call QuickfixClose()<CR>gt
" t : Open result in a new tab but keep results
nnoremap <silent> <buffer> t <C-W><CR><C-W>TgT<C-W><C-W>
