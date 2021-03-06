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
" - markdown: Uses plasticboy/vim-markdown which seem to clear all syntax
"   coloring
let g:polyglot_disabled = ['markdown']
Plug 'sheerun/vim-polyglot'
Plug 'ekalinin/Dockerfile.vim'
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
" Only add coc on machines that have a recent enough version of vim
if v:version >= 801
  let g:oroshi_coc_enabled=1
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  let g:coc_global_extensions = [
    \ 'coc-eslint',
    \ 'coc-prettier',
    \ 'coc-html',
    \ 'coc-json',
    \ 'coc-tsserver'
    \ ]
endif
" }}}
" Git-related plugins {{{
Plug 'airblade/vim-gitgutter'
Plug 'rhysd/committia.vim'
Plug 'tpope/vim-fugitive'
" }}}

" Add plugins to &runtimepath
call plug#end()
