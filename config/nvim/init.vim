" SECURITY {{{
" We disable the "vim: set ai tw=75" type of strings in source files.
" This is used to change nvim settings on a per file basis, but could also allow
" malicious modeline to execute arbitrary code.
" Source: https://github.com/numirias/security/blob/master/doc/2019-06-04_ace-vim-neovim.md
set nomodeline
" }}}
" FILE WRITING {{{
" By default, when saving a file, nvim backs up the original file, in case the
" writing corrupts data. It then deletes the backup file.
" This means that each writes effectively performs three operations (backup,
" save, deletion), which might uselessly trigger tools that react on filesystem
" changes.
" We disable this feature, so only the effective writing is done. In case of an
" issue, the swap feature (see below) should allow recovering the file.
set nobackup
set nowritebackup
" Swap files are used for recovery in case the machine crashes. We store them in
" nvim config directory
set directory=~/.config/nvim/swap//
" Save files automatically as soon as we move to another tab
set autowrite
" }}}
" UNDO {{{
" By default, nvim only saves undo operations for the current vim instance.
" By defining a custom directory to store the undo operations, we can keep our
" undo even days later, in another session.
set undofile
set undolevels=1000
set undodir=~/.config/nvim/undo//
" }}}
" VIEWS {{{
" nvim can also store "views" of files. This contain all information about the
" current file edition. They are stored by default in nvim config
" directory, but because we already store swap and undo data in our local config
" folder, let's add the view there as well
set viewdir=~/.config/nvim/view//
" We only want the cursor and folds
set viewoptions=cursor,folds
" Save sessions on close, load it on open
" The ?* makes it skip non-existing files. Without it, editing large files tend
" to be very slow as I *think* it attempts to calculate folding on each
" character input
" Partial source: https://github.com/spf13/spf13-vim/issues/766
augroup views
  au!
  au BufWinLeave ?* mkview 1
  au BufWinEnter ?* silent loadview 1
augroup END
" }}}

" UI {{{
" Display line number
set number
" Always display the gutter, for consistent rendering
set signcolumn=yes
" Hide  -- INSERT -- or -- VISUAL -- text, we already have it in the statusbar
set noshowmode
" Show more info about current command
set showcmd
" Keep working line as vertically centered as possible
set scrolloff=999
" Hide invisible chars by default, but if they should be displayed, define the
" characters to define them.
set nolist
set listchars=nbsp:∅,tab:▸\ ,eol:↲,trail:·
" Chars used for GUI
set fillchars=stl:\ ,stlnc:\ ,vert:\|,fold:\ ,diff:-
" }}}

" TRIGGERS {{{
source ~/.config/nvim/includes/triggers.vim
" }}}
" COLORS {{{
source ~/.config/nvim/includes/colors.vim
" }}}
