" Specify a directory for plugins
call plug#begin('~/.config/nvim/plugins')

" Run :PlugUpdate to update everything
" Full documentation on https://github.com/junegunn/vim-plug

" Basic vim functions {{{
Plug 'danro/rename.vim'                             " :Rename command
Plug '~/local/src/fzf'                              " Use globally installed fzf
Plug 'junegunn/fzf.vim'                             " Vim-specific fzf plugin
Plug 'junegunn/vim-easy-align'                      " Align text in columns
Plug 'tpope/vim-commentary'                         " gcc to comment/uncomment
Plug 'tpope/vim-abolish'                            " snake_case, camelCase and UPPER_CASE conversion
Plug 'tpope/vim-endwise'                            " Auto-close functions and loops
Plug 'tpope/vim-ragtag'                             " Motions around XML/HTML tags
Plug 'tpope/vim-repeat'                             " Make <Space> also repeat plugin methods
Plug 'tpope/vim-surround'                           " Select or change inside of quotes
Plug 'tpope/vim-unimpaired'                         " Move lines up and down
Plug 'vim-scripts/argtextobj.vim'                   " Motion to select function arguments
" }}}
" Language specific syntax {{{
let g:polyglot_disabled = ['markdown']
Plug 'sheerun/vim-polyglot'                               " All languages
Plug 'aliou/bats.vim'                                     " Bats (bash testing framework)
Plug 'rrethy/vim-hexokinase', { 'do': 'make hexokinase' } " Colors (hexa decimal code)
Plug 'ekalinin/Dockerfile.vim'                            " Docker
Plug 'fladson/vim-kitty', { 'branch': 'main' }            " Kitty
Plug 'vim-ruby/vim-ruby'                                  " Ruby
Plug 'pedrohdz/vim-yaml-folds'                            " Yaml (folding)

" Plug 'StanAngeloff/php.vim'
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
" Note: I had to create a temporary fork of dense-analysis/ale to fix some
" issues with actionlint. I will be able to revert to the official one, once the
" following PRs will be merged:
" - https://github.com/dense-analysis/ale/pull/4688 (only lint current file)
" - https://github.com/dense-analysis/ale/pull/4689 (correctly assign shellcheck line numbers)
Plug 'pixelastic/ale', { 'branch': 'pixelastic' }  " Lint & Fix
Plug 'lifepillar/vim-mucomplete'                   " Completion cycling wrapper
Plug 'github/copilot.vim', { 'branch': 'release' } " GitHub Copilot
Plug 'junegunn/vader.vim'                          " A Vim test framework
" Plug 'natebosch/vim-lsc'         " Completion with LSP
" }}}
" Git-related plugins {{{
Plug 'airblade/vim-gitgutter', { 'branch': 'main' } " Added/Modified signs in the gutter
" Plug 'rhysd/committia.vim'
" Plug 'tpope/vim-fugitive'
" }}}

" Add plugins to &runtimepath
call plug#end()
