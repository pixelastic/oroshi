" FILE EDITING {{{
" BACKUP {{{
" By default, when saving a file, nvim backs up the original file, in case the
" writing corrupts data. It then deletes the backup file.
" This means that each writes effectively performs three operations (backup,
" save, deletion), which might uselessly trigger tools that react on filesystem
" changes.
" We disable this feature, so only the effective writing is done. In case of an
" issue, the swap feature (see below) should allow recovering the file.
set nobackup
set nowritebackup
" }}}
" SWAP {{{
" Swap files are used for recovery in case the machine crashes. We store them in
" nvim config directory
set directory=~/.config/nvim/swap//
" }}}
" AUTOWRITE {{{
" Save files automatically as soon as we move to another tab
set autowrite
" }}}
" AUTOREAD {{{
" Reload files when changed from outside
set autoread
augroup autoread
  autocmd!
  autocmd CursorHold ?* checktime
  autocmd TabEnter ?* checktime
augroup END
" }}}
" WORKING DIRECTORY {{{
" By default, vim considers the shell working directory as vim working
" directory. This means that a ":tabe " will only suggest files in the shell
" working directory, not in the current file working directory.
" This autocmd will set the current working directory as the current file
" directory.
" A vim option, "set autochdir" exists to do the same, but seems to confuse some
" plugins (comittia and vimdeck)
augroup autochdir
  autocmd!
  autocmd BufEnter * silent! lchdir %:p:h
augroup END
" }}}
