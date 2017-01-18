" Specify a directory for plugins
call plug#begin('~/.vim/plugins')

" Run :PlugUpdate to update everything
" Full documentation on https://github.com/junegunn/vim-plug

" Basic vim functions {{{
Plug 'danro/rename.vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'pixelastic/rainbow_parentheses.vim'
Plug 'pixelastic/vim-undodir-tree'
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
Plug 'digitaltoad/vim-jade'
Plug 'evanmiller/nginx-vim-syntax'
Plug 'groenewege/vim-less'
Plug 'hail2u/vim-css3-syntax'
Plug 'kchmck/vim-coffee-script'
Plug 'mxw/vim-jsx'
Plug 'othree/html5.vim'
Plug 'pangloss/vim-javascript'
Plug 'tmhedberg/SimpylFold' " Python folding
Plug 'tpope/vim-markdown'
Plug 'vim-ruby/vim-ruby'
" }}}
" Enhancing vim workflow {{{
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'mattn/emmet-vim'
Plug 'scrooloose/syntastic'
" }}}
" Git-related plugins {{{
Plug 'airblade/vim-gitgutter'
Plug 'rhysd/committia.vim'
Plug 'tpope/vim-fugitive'
" }}}

" Add plugins to &runtimepath
call plug#end()
