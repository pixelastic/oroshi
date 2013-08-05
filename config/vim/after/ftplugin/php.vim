" PHP
" Faster typing of $this->
inoremap $< $this->
inoremap $> $this->
inoremap $$ $this->
" <C-X>= adds <?php echo | ?> even in normal mode
nmap <C-X>= i<C-X>=
" <C-X>- adds <?php | ?> even in normal mode
nmap <C-X>- i<C-X>-
nmap <C-X>i i<C-X>-
imap <C-X>i <C-X>-
" Enable folding
let g:php_folding=2
