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
" Reload files when changed from outside
set autoread
augroup autoread
  au!
  autocmd CursorHold ?* checktime
  autocmd TabEnter ?* checktime
augroup END
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

" UI {{{
" Display line number
set number
" Always display the gutter, for consistent rendering
set signcolumn=yes
" Coloring current line
set cursorline
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

" FUNCTIONS {{{
source ~/.config/nvim/includes/functions.vim
" }}}
" TRIGGERS {{{
source ~/.config/nvim/includes/triggers.vim
" }}}
" TABS {{{
source ~/.config/nvim/includes/tabs.vim
" }}}
" INDENTATION {{{
source ~/.config/nvim/includes/indentation.vim
" }}}
" KEYBINDINGS {{{
source ~/.config/nvim/includes/keybindings.vim
" }}}
" COLORS {{{
source ~/.config/nvim/includes/colors.vim
" }}}
" STATUS LINE {{{
source ~/.config/nvim/includes/statusline/index.vim
"}}}
" SEARCH {{{
source ~/.config/nvim/includes/search.vim
"}}}
" COMPLETION {{{
" Height of the (scrollable) autocompletion window
set pumheight=10
" }}}
" COMMANDS {{{
" Keep more commands in history
set history=1000
" Save file using sudo
cnoremap w!! w !sudo tee '%' >/dev/null<CR><CR>
" }}}
" FOLDING  {{{
source ~/.config/nvim/includes/folding.vim
"}}}
" TEXT WRAPPING {{{
" Lines too long to fit on one screen will be truncated.
set nowrap
let &showbreak='↪ '
" Force a 79 column policy with an auto-break on words in comments to assure
" maximum readability. Visually add a column to see where the cut will be.
set linebreak
set colorcolumn=81
set textwidth=80
" Create two format modes, for code and for text
" c : Comments are wrapped based on textwidth
" r : New line in comment is a comment when pressing <Enter>
" o : New line in comment is a comment when pressing 'o'
" n : Handles list while formatting
" q : Comments can be re-wrapped using gq
" 1 : Do not end lines with one-char words
set formatoptions=cronq1
" We make sure that backspace in insert mode can delete new lines and tabs
set backspace=indent,eol,start
" Format whole paragraph
nnoremap gqp mzvipgq`z
"}}}
" SNIPPETS  {{{
" Lorem ipsum
iabbrev lorem Lorem ipsum dolor sit amet, consectetur adipiscing elit
iabbrev llorem Lorem ipsum dolor sit amet, consectetur adipiscing elit.  Etiam lacus ligula, accumsan id imperdiet rhoncus, dapibus vitae arcu.  Nulla non quam erat, luctus consequat nisi
iabbrev lllorem Lorem ipsum dolor sit amet, consectetur adipiscing elit.  Etiam lacus ligula, accumsan id imperdiet rhoncus, dapibus vitae arcu.  Nulla non quam erat, luctus consequat nisi.  Integer hendrerit lacus sagittis erat fermentum tincidunt.  Cras vel dui neque.  In sagittis commodo luctus.  Mauris non metus dolor, ut suscipit dui.  Aliquam mauris lacus, laoreet et consequat quis, bibendum id ipsum.  Donec gravida, diam id imperdiet cursus, nunc nisl bibendum sapien, eget tempor neque elit in tortor
" }}}
" SPLIT {{{
" Splitting right and bottom feels more natural
set splitright
set splitbelow
" Use Arrow in normal mode to move accros splits
nnoremap <Up> <C-W>k
nnoremap <Right> <C-W>l
nnoremap <Down> <C-W>j
nnoremap <Left> <C-W>h
"}}}


" TYPOS {{{
iabbrev Gvien Given
iabbrev initialiaeze initialize
iabbrev initialiaze initialize
iabbrev initiliaze initialize
iabbrev intiialiaee initialize
iabbrev intiialiaze initialize
iabbrev intiialize initialize
" }}}
" YANK / PASTE   {{{
" Note: Systems have two different clipboards.
" unnamed is (select text / middle click) and accessed with "*
" unnamedplus is (Ctrl+C / Ctrl+V) and accessed with "+
" We only use unnamed plus, if available
set clipboard=
if has('unnamedplus')
  set clipboard+=unnamedplus
endif

vnoremap p "_dP
vnoremap P "_dP
" As gv selects last selected text, we add gp to select last pasted text
nnoremap gp `[v`]
" We'll use x as a way to delete text without keeping it in a paste buffer
nnoremap x "_x
vnoremap x "_x
" [c]hanging a word does not put it in yank buffer
nnoremap c "_c
" }}}
"}}}

" GIT {{{
let g:gitgutter_max_signs=10000
" }}}
" SYNTASTIC {{{
let g:syntastic_aggregate_errors=1
let g:syntastic_auto_loc_list=0
let g:syntastic_always_populate_loc_list=1
let g:syntastic_error_symbol=' '
let g:syntastic_style_error_symbol=' '
let g:syntastic_warning_symbol=' '
let g:syntastic_style_warning_symbol=' '
let g:syntastic_mode_map={ 'mode': 'passive',
                     \ 'active_filetypes': [
                       \ 'ansible',
                       \ 'css', 'scss',
                       \ 'dockerfile',
                       \ 'html', 'pug',
                       \ 'javascript',
                       \ 'json',
                       \ 'vue',
                       \ 'markdown',
                       \ 'php',
                       \ 'python',
                       \ 'ruby',
                       \ 'bash', 'sh', 'zsh',
                       \ 'vim',
                       \ 'yaml',
                       \ 'xml'
                     \ ],
                     \ 'passive_filetypes': [] }
" }}}
" COC {{{
source ~/.config/nvim/includes/coc.vim
" }}}
" FILETYPES {{{
" Load skeletons
augroup skeletons
  au!
  au BufNewFile * :silent! exec ":0r ~/.config/nvim/includes/skeletons/skeleton.".expand('%:e')
augroup END

" ,ve to edit vimrc
nnoremap <leader>ve :tabe ~/.oroshi/config/vim/vimrc<CR>
" ,vr to reload vimrc
nnoremap <leader>vr mz:source ~/.config/nvim/init.vim<CR>:let &filetype=&filetype<CR>:loadview<CR>:nohlsearch<CR>`z 
" man to open the manpage of a command in a new tab
nnoremap <silent> man :tabe<CR>:setlocal filetype=man<CR>:.!man<Space>
" }}}


" Custom Config {{{
let hostname = system('echo -n $HOST')
let customConfig=expand("~/.oroshi/config/nvim/local/".hostname.".vim")
if filereadable(customConfig)
  exec "source ".customConfig
endif
" }}}
