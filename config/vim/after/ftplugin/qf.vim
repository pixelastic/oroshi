" QUICK FIX / LOCATION LIST
" QuickfixClose() {{{
if !exists('*QuickfixClose')
	function! QuickfixClose()
    " Not really a quickfix window, we do nothin
		if &ft != "qf"
			return ""
		endif
    " Last opened window, we'll need to force quit
    if winbufnr(2) == -1
       quit!
    endif
    " Simply close it
		cclose
		lclose
	endfunction
endif
" }}}

" Ctrl-D closes quickfix window
nnoremap <silent> <buffer> <C-D> :call QuickfixClose()<CR>
" Enter : open result in new tab, go to tab and close results
nnoremap <silent> <buffer> <CR> <C-W><CR><C-W>TgT:call QuickfixClose()<CR>gt
" t : Open result in a new tab but keep results
nnoremap <silent> <buffer> t <C-W><CR><C-W>TgT<C-W><C-W>
