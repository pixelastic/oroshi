" HTML
" Indenting {{{
" Use two spaces for indenting
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab
" }}}
" Wrapping {{{
" Extend line-width to 140
if &ft == "html"
	setlocal colorcolumn=140
	setlocal textwidth=139
endif
" }}}
" Folding {{{
setlocal foldmethod=manual
function! HTMLFoldTag()
	if foldclosed('.')==-1
		normal zfat
	else
		normal zO
	endif
endfunction
" Note: We only want this mapping for html files, not markdown or other types
" using using this ftplugin file.
if &ft == "html"
  nnoremap <silent> <buffer> za :call HTMLFoldTag()<CR>
endif
" }}}
" Syntax checking {{{
let g:syntastic_html_tidy_ignore_errors = [
                \ "trimming empty <i>",
                \ "trimming empty <span>",
                \ "trimming empty <em>",
                \ "proprietary attribute \"ng-",
                \ "proprietary attribute \"ui-",
								\ "<img> lacks \"src\" attribute"
                \ ]
" }}}
" Cleaning the file {{{
inoremap <silent> <buffer> <F4> <Esc>:call HtmlBeautify()<CR>
nnoremap <silent> <buffer> <F4> :call HtmlBeautify()<CR>
function! HtmlBeautify() 
	let linenr=line('.')
	execute '%!html-beautify -f -'
	call RemoveTrailingSpaces()
	execute 'normal '.linenr.'gg'
endfunction
" }}}
" Remove scripts from file {{{
function! b:RemoveScripts()
	let @z = 'gg/<scriptdat@z'
	silent normal @z
	" TODO: Find a cleaner way to not show the error message at the end of the
	" recursive macro.
	redraw!
endfunction
nnoremap <buffer> O1;5S :call b:RemoveScripts()<CR>
" }}}
" Run file {{{
nnoremap <silent> <buffer> <F5> :call OpenUrlInBrowser(expand('%:p'))<CR>
" }}}

" Ctrl+C closes opened tags (using ragtags)
imap <buffer> <C-c> <C-X>/<Esc>mzvat=`zi<Right>
" Ctrl+E expands zen-coding string (using emmet)
imap <buffer> <C-e> <C-Y>,
" Ctrl+B adds a <br />
inoremap <buffer> <C-b> <br /><CR>
nnoremap <buffer> <C-b> i<br /><CR><Esc>


" TODO: Add those angular tags to html5.vim config
" g:html_exclude_tags
" | +" AngularJS default directives
" | +call add(s:tags, 'ng-include')
" | +
" | +" AngularJS bootstrap custom directives
" | +call add(s:tags, 'accordion')
" | +call add(s:tags, 'accordion-group')
" | +call add(s:tags, 'accordion-heading')
" | +call add(s:tags, 'alert')
" | +call add(s:tags, 'carousel')
" | +call add(s:tags, 'datepicker')
" | +call add(s:tags, 'pager')
" | +call add(s:tags, 'pagination')
" | +call add(s:tags, 'progress')
" | +call add(s:tags, 'progressbar')
" | +call add(s:tags, 'rating')
" | +call add(s:tags, 'slide')
" | +call add(s:tags, 'tab')
" | +call add(s:tags, 'tabset')
" | +call add(s:tags, 'timepicker')
"


