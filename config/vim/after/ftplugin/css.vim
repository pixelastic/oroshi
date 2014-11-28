" CSS
" Misc {{{
" - delimits words in css
setlocal iskeyword-=-
" }}}
" Indentation rules {{{
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab
setlocal equalprg=css-beautify\ -s\ 2\ -f\ -
" }}}
" Folding {{{
setlocal foldmethod=marker
setlocal foldmarker={,}
" }}}
" Custom bindings {{{
" is stands for [i]n [s]elector, #header li
noremap <buffer> is :<c-u>execute "normal! ?{\r:nohlsearch\r^vt{h"<CR>
nunmap  <buffer> is
" ip stands for [i]n [p]roperty, background-color
noremap <buffer> ip :<C-U>normal! ^vt:<CR>
nunmap  <buffer> ip
" iv stands for [i]n [v]alue, 3px solid red
noremap <buffer> iv :<C-U>normal! ^f:lvt;<CR>
nunmap  <buffer> iv
" ir stands for [i]n [r]ules,  { ... }
noremap <buffer> ir iB
nunmap  <buffer> ir
" ar stands for [a]round [r]ules, selector { ... }
noremap <buffer> ar :<C-U>execute "normal! ?{\rV/}\r"<CR>
nunmap  <buffer> ar
" }}}
" Csslint checker {{{
let g:syntastic_css_checkers = ['csslint', 'recess']
let g:syntastic_aggregate_errors = 1
if !exists('g:syntastic_css_csslint_options') || g:syntastic_css_csslint_options==''
	let g:syntastic_css_csslint_options = system('cat '.expand('~/.csslintrc'))
endif
if !exists('g:syntastic_css_recess_args') || g:syntastic_css_recess_args==''
	let g:syntastic_css_recess_args = '--strictPropertyOrder false --noOverqualifying false'
endif
"}}}
" Cleaning the file {{{
nnoremap <silent> <buffer> <F4> :call CssBeautify()<CR>
function! CssBeautify() 
	execute '%!css-beautify -s 2 -f -'
	call RemoveTrailingSpaces()
endfunction
" }}}
