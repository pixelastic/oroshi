" VIEWS {{{
" nvim can also store "views" of files. This contain all information about the
" current file edition. They are stored by default in nvim config
" directory, but because we already store swap and undo data in our local config
" folder, let's add the view there as well
set viewdir=~/.config/nvim/view//
" We only want the cursor and folds
set viewoptions=cursor,folds
" Save sessions on save/close/switch, load it on open
" The ?* makes it skip non-existing files
augroup views
  autocmd!
  " Save the view when...
  " ...switching tabs, closing a tab
  autocmd BufLeave ?* silent! mkview 1
  " ...saving a file
  autocmd BufWrite ?* mkview 1
  " ...closing the last tab (BufLeave does not trigger in that case)
  autocmd VimLeavePre ?* mkview 1

  " Reload it when...
  " ...entering the tab
  autocmd BufWinEnter ?* silent! loadview 1

  " We also make sure to move the cursor to the first column when opening a new
  " file so the text is always left aligned
  autocmd BufWinEnter * normal 0
augroup END
" }}}
