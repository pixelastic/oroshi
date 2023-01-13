" Specify a directory for plugins
call plug#begin('~/.config/nvim/plugins')

" Run :PlugUpdate to update everything
" Full documentation on https://github.com/junegunn/vim-plug

" Basic vim functions {{{
Plug 'danro/rename.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/vim-easy-align'
Plug 'pixelastic/vim-undodir-tree'
Plug 'gioele/vim-autoswap'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-ragtag'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'vim-scripts/argtextobj.vim'
" }}}
" Language specific syntax {{{
" All languages
Plug 'sheerun/vim-polyglot'
" Bats (bash testing framework)
Plug 'aliou/bats.vim'
" Colors (hexa decimal code)
Plug 'rrethy/vim-hexokinase', { 'do': 'make hexokinase' }
" Docker
Plug 'ekalinin/Dockerfile.vim'
" Kitty
Plug 'fladson/vim-kitty', { 'branch': 'main' }
" Ruby
Plug 'vim-ruby/vim-ruby'

" Plug 'StanAngeloff/php.vim'
" Plug 'avakhov/vim-yaml'
" Plug 'cakebaker/scss-syntax.vim'
" Plug 'cespare/vim-toml'
" Plug 'chase/vim-ansible-yaml'
" Plug 'digitaltoad/vim-pug'
" Plug 'groenewege/vim-less'
" Plug 'hail2u/vim-css3-syntax'
" Plug 'othree/html5.vim'
" Plug 'pangloss/vim-javascript'
" Plug 'tmhedberg/SimpylFold' " Python folding
" Plug 'tpope/vim-markdown'
" }}}
" Enhancing vim workflow {{{
Plug 'sbdchd/neoformat'
Plug 'scrooloose/syntastic'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" }}}
" Git-related plugins {{{
Plug 'airblade/vim-gitgutter'
Plug 'rhysd/committia.vim'
Plug 'tpope/vim-fugitive'
" }}}

" Add plugins to &runtimepath
call plug#end()
