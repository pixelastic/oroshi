" PHP
" Faster typing of $this->
inoremap $< $this->
inoremap $> $this->
inoremap $$ $this->

" Note: Indenting in mixed php/html files is buggy. We need to pass in ft=phtml
" first when indenting, and reverting to php when done.
" Allow re-indenting of mixed php/html using the phtml syntax
vnoremap <silent> = <Esc>:set ft=phtml<CR>gv=:set ft=php<CR>
nnoremap <silent> == :set ft=phtml<CR>==:set ft=php<CR>
" Allow ragtags <C-X>= and <C-X>- to indent and work in normal mode as well
imap <C-X>= <C-X>=<Esc>==i
nmap <C-X>= i<C-X>=
imap <C-X>- <C-X>-<Esc>==i
nmap <C-X>- i<C-X>-
imap <C-X>i <C-X>-
nmap <C-X>i <C-X>-

" Enable folding
let g:php_folding=2


