" CSS
" Misc {{{
" Remove - and _ from delimiters
setlocal iskeyword=@,48-57,192-255
" }}}
" Indentation rules {{{
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab
setlocal equalprg=css-beautify\ -s\ 2\ -f\ -
" }}}
" Folding {{{
setlocal foldmethod=syntax
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
" Linters {{{
let b:repo_root = GetRepoRoot()
let b:syntastic_checkers = ['stylelint']
" Use the local stylelint if one is defined in the repo
if filereadable(b:repo_root . '/.stylelintrc') || filereadable(b:repo_root . '/.stylelintrc.js')
  let b:syntastic_css_stylelint_exec = StrTrim(system('npm-which stylelint'))
end
" postCSS emulates many of the features of CSS, but we're not using it in every
" project yet, so we only whitelist the directories where it should add specific
" config
if expand('%:p') =~# 'tachyons-algolia'
  " Allow gcc to set // comments
  setlocal commentstring=//\ %s
  " Make sure stylelint understand SCSS config even in CSS files
  let g:syntastic_css_stylelint_args = '--syntax scss'
endif
"}}}
" Cleaning the file {{{
nnoremap <silent> <buffer> <F4> :call CssBeautify()<CR>
function! CssBeautify() 
	execute '%!css-beautify -s 2 -f -'
	call RemoveTrailingSpaces()
endfunction
" }}}
