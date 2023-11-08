source ~/.config/nvim/includes/nvim.vim            " nvim-specific, as high as possible
source ~/.config/nvim/includes/security.vim        " security protections
source ~/.config/nvim/includes/encoding.vim        " encoding
source ~/.config/nvim/includes/plugins.vim         " loading plugins
source ~/.config/nvim/includes/functions/index.vim " loading functions


source ~/.config/nvim/includes/completion.vim        " Completion
source ~/.config/nvim/includes/keybindings/index.vim " Keybindings
source ~/.config/nvim/includes/statusline/index.vim  " Statusline
source ~/.config/nvim/includes/plugins/index.vim     " Plugin configuration

source ~/.config/nvim/includes/colors.vim
source ~/.config/nvim/includes/display.vim
source ~/.config/nvim/includes/file-editing.vim
source ~/.config/nvim/includes/folding.vim
source ~/.config/nvim/includes/git.vim
source ~/.config/nvim/includes/indentation.vim
source ~/.config/nvim/includes/jumps.vim
source ~/.config/nvim/includes/search.vim
source ~/.config/nvim/includes/snippets.vim
source ~/.config/nvim/includes/split.vim
source ~/.config/nvim/includes/tabs.vim
source ~/.config/nvim/includes/text-wrapping.vim
source ~/.config/nvim/includes/triggers.vim
source ~/.config/nvim/includes/typos.vim
source ~/.config/nvim/includes/undo.vim
source ~/.config/nvim/includes/views.vim
source ~/.config/nvim/includes/yank.vim

" COMMANDS {{{
" Keep more commands in history
set history=1000
" Save file using sudo
cnoremap w!! w !sudo tee '%' >/dev/null<CR><CR>
" }}}
"
" We make sure that backspace in insert mode can delete new lines and tabs
set backspace=indent,eol,start



" FILETYPES {{{
" Load skeletons
augroup skeletons
  au!
  au BufNewFile * :silent! exec ":0r ~/.config/nvim/includes/skeletons/skeleton.".expand('%:e')
augroup END

" ,ve to edit vimrc
nnoremap <leader>ve :tabe ~/.oroshi/config/vim/vimrc<CR>
" ,vr to reload vimrc
nnoremap <silent> <leader>vr mz:source ~/.config/nvim/init.vim<CR>:let &filetype=&filetype<CR>:nohlsearch<CR>`z
" man to open the manpage of a command in a new tab
nnoremap <silent> man :tabe<CR>:setlocal filetype=man<CR>:.!man<Space>
" }}}
