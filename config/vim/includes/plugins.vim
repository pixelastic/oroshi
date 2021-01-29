" Specify a directory for plugins
call plug#begin('~/.vim/plugins')

" Run :PlugUpdate to update everything
" Full documentation on https://github.com/junegunn/vim-plug

" Basic vim functions {{{
Plug 'danro/rename.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'pixelastic/vim-undodir-tree'
Plug 'gioele/vim-autoswap'
Plug 'tpope/vim-commentary'
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
let g:polyglot_disabled = []
" javascript has better highlight than jsonc, and I don't comment my JSON anyway
call add(g:polyglot_disabled, 'jsonc')
Plug 'sheerun/vim-polyglot'
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
" Plug 'vim-ruby/vim-ruby'
" }}}
" Enhancing vim workflow {{{
Plug 'sbdchd/neoformat'
Plug 'scrooloose/syntastic'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
let g:coc_global_extensions = [
  \ 'coc-json',
  \ 'coc-html'
  \ ]
" }}}
" Git-related plugins {{{
Plug 'airblade/vim-gitgutter'
Plug 'rhysd/committia.vim'
Plug 'tpope/vim-fugitive'
" }}}

" Add plugins to &runtimepath
call plug#end()
