" COMPLETION
" TODO: Completion of directories should add the final / when selecting one,
" allowing for chaining path
" TODO: Completion of files should not suggest buffer if no path found
" Notes about completion in vim {{{
"
" Completion in vim is made of different layers
"
" Default completion is enabled through <C-X><Something>. <Something> can be
" <C-F> for File completion, or <C-V> for Vimscript completion, etc. Moving to
" next/previous element is done through <C-N>/<C-P> once the menu is opened.
" <C-Y> selects the item, while <C-E> cancels the selection.
"
" We manually remapped completion (and iteration) to <Tab>. Selection is done
" through <Enter> and cancel through <C-C>
"
" MUComplete is used as a wrapper on top of the completion system, to provide
" completions in buckets. First, it looks for completion in a first bucket of
" suggestions; if doesn't find anything, it moves to the next bucket and so on.
"
" This allows looking for known variables, and if none is found, check for known
" words for example. It also allows defining filetype specific bucket lists.
"
" One of the possible completion methods offered by MUComplete (and bare vim) is
" called omnicomplete. It's a language-aware completion system for vim. It is
" not enabled by default, as one needs to define the `omnifunc` variable to
" a completion function.
"
" Vim comes bundled with the `syntaxcomplete#Complete` but more specific
" functions can be defined for specific languages.
"
" TODO: See below, using LSP
"
" NVIM allows for asynchronous called to external commands, which can allow
" Language Server Protocols (or LSP for short) to be used. See https://langserver.org/
" LSP are a set of standardize structure format to represent and interact with
" a language AST. Each language has its own official LSP, that can be used by
" IDEs.
"
" In vim, there are a bunch of different LSP plugins that can interact with
" those official LSP. ALE (that we already use for linting) has one. Coc (that
" I used to use) has one as well. vim-lsc is another barebone one.
"
" Our final setup uses:
" - MUComplete to trigger the keybindings and cycle through the completion systems
" - a default omnifunc for all languages
" - a custom omnifunc for specific languages, that uses vim-lsc
" }}}

set pumheight=10          " Height of the (scrollable) autocompletion window
set completeopt+=menuone  " Display the menu even if there is only one match
set completeopt+=noinsert "
set completeopt+=noselect " Only update the text once an item is selected
set shortmess+=c          " Do not display completion messages in the message line
set complete-=i           " Do not include patterns from included files by default
set complete-=t           " Do not include CTAG by default (will be handled by omnifunc)

" Set a default omnifunc if none is specifically set for this filetype
augroup OmnifuncDefault
	autocmd Filetype *
				\	if &omnifunc == '' |
				\		setlocal omnifunc=syntaxcomplete#Complete |
				\	endif
augroup end

" MUComplete {{{
" Checks in one bucket of completion, if can't find it in the next one and so on
" https://github.com/lifepillar/vim-mucomplete

" Disable default mapping, as we already have [Ctrl-H] mapped to previous tab
" We'll remap them manually (check in keybindings/*.vim)
let g:mucomplete#no_mappings='1'

" Possible completions. See `:help mucomplete-methods` for details {{{
" c-n  | As defined in `complete`
" omni | As defined in `omnifunc`
" cmd  | Vim methods
" path | file paths
" keyn | Keywords in current file (forward)
" keyp | Keywords in current file (backward)
" incl | Keywords in current and included files
" uspl | Spelling
" list | Custom list of words
" dict | Keywords in dictionary
" }}}

let g:mucomplete#chains = {}
let g:mucomplete#chains['default'] = {
	\ 'default': ['omni', 'c-n'],
	\ }
" let g:mucomplete#chains['vim'] = {
"   \ 'default': ['path', 'cmd', 'keyn'],
" 	\ 'vimString': [],
"   \ 'vimLineComment': ['uspl'],
" 	\ }
" }}}

" vim-lsc {{{
" let g:lsc_enable_autocomplete = v:false
" }}}
