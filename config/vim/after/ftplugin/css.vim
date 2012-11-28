" CSS
" Remove unwanted trailing whitespaces
au BufWritePre,BufRead <buffer> call RemoveTrailingSpaces()

" Use language { and } as fold markers
setlocal foldmethod=marker
setlocal foldmarker={,}

" is stands for [i]n [s]elector, #header li
noremap <buffer> is :<c-u>execute "normal! ?{\r:nohlsearch\r^vt{h"<CR>
nunmap  <buffer> is
" ir stands for [i]n [r]ules,  { ... }
noremap <buffer> ir iB
nunmap  <buffer> ir
" ar stands for [a]round [r]ules, selector { ... }
noremap <buffer> ar :<C-U>execute "normal! ?{\rV/}\r"<CR>
nunmap  <buffer> ar
" ip stands for [i]n [p]roperty, background-color
noremap <buffer> ip :<C-U>normal! ^vt:<CR>
nunmap  <buffer> ip
" iv stands for [i]n [v]alue, 3px solid red
noremap <buffer> iv :<C-U>normal! ^f:lvt;<CR>
nunmap  <buffer> iv

" TODO: Add b:CleanFile
