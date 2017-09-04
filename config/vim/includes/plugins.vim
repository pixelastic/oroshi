" Specify a directory for plugins
call plug#begin('~/.vim/plugins')

" Run :PlugUpdate to update everything
" Full documentation on https://github.com/junegunn/vim-plug

" Basic vim functions {{{
Plug 'danro/rename.vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'pixelastic/vim-undodir-tree'
Plug 'gioele/vim-autoswap'
Plug 'tomtom/tcomment_vim'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-ragtag'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'vim-scripts/Align'
Plug 'vim-scripts/argtextobj.vim'
" }}}
" Language specific syntax {{{
Plug 'StanAngeloff/php.vim'
Plug 'ap/vim-css-color'
Plug 'avakhov/vim-yaml'
Plug 'cakebaker/scss-syntax.vim'
Plug 'cespare/vim-toml'
Plug 'chase/vim-ansible-yaml'
Plug 'digitaltoad/vim-pug'
Plug 'evanmiller/nginx-vim-syntax'
Plug 'groenewege/vim-less'
Plug 'hail2u/vim-css3-syntax'
Plug 'mxw/vim-jsx'
Plug 'othree/html5.vim'
Plug 'pangloss/vim-javascript'
Plug 'posva/vim-vue'
Plug 'tmhedberg/SimpylFold' " Python folding
Plug 'tpope/vim-markdown'
Plug 'vim-ruby/vim-ruby'
" }}}
" Enhancing vim workflow {{{
Plug 'mattn/emmet-vim'
Plug 'sbdchd/neoformat'
Plug 'scrooloose/syntastic'
" }}}
" Git-related plugins {{{
Plug 'airblade/vim-gitgutter'
Plug 'rhysd/committia.vim'
Plug 'tpope/vim-fugitive'
" }}}

" Add plugins to &runtimepath
call plug#end()
