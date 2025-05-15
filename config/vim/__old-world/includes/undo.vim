" UNDO {{{
" By default, nvim only saves undo operations for the current vim instance.
" By defining a custom directory to store the undo operations, we can keep our
" undo even days later, in another session.
set undofile
set undolevels=1000
set undodir=~/.config/nvim/undo//
" }}}
