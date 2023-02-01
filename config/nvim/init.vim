source ~/.config/nvim/includes/security.vim
source ~/.config/nvim/includes/encoding.vim
source ~/.config/nvim/includes/plugins.vim
source ~/.config/nvim/includes/functions.vim
source ~/.config/nvim/includes/completion.vim

source ~/.config/nvim/includes/keybindings/index.vim
" source ~/.config/nvim/includes/statusline/index.vim
source ~/.config/nvim/includes/plugins/index.vim

source ~/.config/nvim/includes/colors.vim
source ~/.config/nvim/includes/display.vim
source ~/.config/nvim/includes/file-editing.vim
source ~/.config/nvim/includes/folding.vim
source ~/.config/nvim/includes/indentation.vim
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
source ~/.config/nvim/includes/git.vim

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
nnoremap <leader>vr mz:source ~/.config/nvim/init.vim<CR>:let &filetype=&filetype<CR>:nohlsearch<CR>`z 
" man to open the manpage of a command in a new tab
nnoremap <silent> man :tabe<CR>:setlocal filetype=man<CR>:.!man<Space>
" }}}


" Custom Config {{{
let hostname = system('echo -n $HOST')
let customConfig=expand('~/.oroshi/config/nvim/local/'.hostname.'.vim')
if filereadable(customConfig)
  exec 'source '.customConfig
endif
" }}}
