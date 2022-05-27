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
  au!
  " Save the view when...
  " ...switching tabs, closing a tab
  au BufLeave ?* mkview 1
  " ...saving a file
  au BufWrite ?* mkview 1
  " ...closing the last tab (BufLeave does not trigger in that case)
  au VimLeavePre ?* mkview 1

  " Reload it when...
  " ...entering the tab
  au BufWinEnter ?* silent! loadview 1
augroup END
" }}}
