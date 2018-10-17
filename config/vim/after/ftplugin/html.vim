" HTML
" Word selection {{{
setlocal iskeyword=@,48-57,192-255
" }}}
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
" Resetting folds with zr
nnoremap <silent> <buffer>  zr :set foldmethod=syntax<CR>:set foldmethod=manual<CR>
" Note: We only want this mapping for html files, not markdown or other types
" using using this ftplugin file.
if &ft == "html"
  nnoremap <silent> <buffer> za :call HTMLFoldTag()<CR>
endif
" }}}
" Syntax checking {{{
let b:syntastic_html_tidy_exec = '~/.oroshi/scripts/bin/tidycheck'
" }}}
" Cleaning the file {{{
inoremap <silent> <buffer> <F4> <Esc>:call HtmlBeautify()<CR>
nnoremap <silent> <buffer> <F4> :call HtmlBeautify()<CR>
function! HtmlBeautify() 
  let linenr=line('.')
  execute '%!html'
  execute 'normal '.linenr.'gg'
endfunction
" }}}
" Keybindings {{{
" $ù is easy to type on my keyboard. Use it for debug calls
inoremap <buffer> $ù console.info(
" }}}
" Run file with Shift-F5 {{{
nnoremap <silent> <buffer> [31~ :call OpenUrlInBrowser(expand('%:p'))<CR>
" }}}

" Ctrl+C closes opened tags (using ragtags)
imap <buffer> <C-c> <C-X>/<Esc>mzvat=`zi<Right>
" Ctrl+E expands zen-coding string (using emmet)
imap <buffer> <C-e> <C-Y>,
" Ctrl+B adds a <br />
inoremap <buffer> <C-b> <br /><CR>
nnoremap <buffer> <C-b> i<br /><CR><Esc>

