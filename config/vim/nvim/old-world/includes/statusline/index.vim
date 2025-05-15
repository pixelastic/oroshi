" STATUS LINE
source ~/.config/nvim/includes/statusline/git.vim
source ~/.config/nvim/includes/statusline/filetype.vim
source ~/.config/nvim/includes/statusline/project.vim

" Always display the status line
set laststatus=2
" Custom statusline
set statusline=%!OroshiStatusLine()
" Hide  -- INSERT -- or -- VISUAL -- text, we already have it in the statusbar
set noshowmode

" Building the statusline
" This will be called whenever a redraw is needed, so basically whenever we type
" something or move the cursor around.
" As a rule, no expensive operation, like making a system() call should be done
" in the statusline. If such a call is needed (for example to gather Git stats),
" it should be done outside of the OroshiStatusLine() method and shared through
" a variable when available.
let b:oroshiStatusLineGitStatus = ''

function! OroshiStatusLine()
  let sl = ''

  " Current mode {{{
  let rawMode = mode()
  let modeName = 'Unknown'
  if rawMode ==# 'n' | let modeName = 'Normal' | endif
  if rawMode ==# 'i' | let modeName = 'Insert' | endif
  " Both Search and Command are identified by "c", but we can check the content
  " of the commandline to see if it's a search ("\v") or a command
  if rawMode ==# 'c'
    let commandLine = getcmdline()
    if commandLine =~? '^\\v'
      let modeName = 'Search'
    else
      let modeName = 'Command'
    endif
  endif
  if rawMode ==? 'v' || rawMode ==# ''
    let modeName = 'Visual'
  endif
  let sl .= '%#StatusLineMode'.modeName.'# '.toupper(modeName).' %*'
  let sl .= '%#StatusLineMode'.modeName.'Separator#%*'
  " }}}

  " Current project {{{
  " Guess the project based on the filename on first call, then keep it in cache
  if !exists('b:oroshiStatusLineProject')
    let b:oroshiStatusLineProject = StatusLineGetProject()
  endif
  if b:oroshiStatusLineProject !=# ''
    let sl .= b:oroshiStatusLineProject.' '
  endif
  " }}}

  " Current file {{{
  let filepath = expand('%:p:h:t').'/'.expand('%:t')
  let isWritable = &readonly == 0
  let hasUnsavedChanges = &modified
  if isWritable
    if hasUnsavedChanges
      let sl .= '%#StatusLinePathModified#'.filepath.' %*'
    else
      let sl .= '%#StatusLinePath#'.filepath.' %*'
    endif
  else
    let sl .= '%#StatusLinePathReadonly#'.filepath.' %*'
  endif
  " }}}

  " Git repo status {{{
	if exists('b:oroshiStatusLineGitStatus') && b:oroshiStatusLineGitStatus !=# ''
    let sl .= '%#StatusLineGit'.b:oroshiStatusLineGitStatus.'#ﰖ%* '
  endif
  " }}}

  " Linting errors {{{
  " Note: When we load vim for the first time, and Ale isn't yet installed, this
  " part of the code will trigger a lot of errors. So, we wrap it, to only
  " conditionally add the errors if ale is ready
  if exists('g:loaded_ale')
    let rawErrors = ale#statusline#Count(bufnr(''))
    let errorCount = rawErrors.error + rawErrors.style_error
    let warningCount = rawErrors.warning + rawErrors.style_warning
    if errorCount !=# 0
      let sl .= '%#StatusLineLintError# '.errorCount.' %*'
    endif
    if warningCount !=# 0
      let sl .= '%#StatusLineLintWarning# '.warningCount.' %*'
    endif
  else
      let sl .= '%#StatusLineLintError# Ale not installed%*'
  endif

  " }}}

  " Line endings {{{
  if &fileformat !=# 'unix'
    let sl .= '%#StatusLineFileFormatError# '.&fileformat.' %*'
  endif
  " }}}

  " File encoding {{{
  " A file in vim is read in the encoding defined in &encoding, but saved in the
  " one defined in &fileencoding. If &fileencoding is empty, it fallbacks to
  " &encoding
  let fileEncoding = &fileencoding || &encoding
  if fileEncoding !=# 'utf-8'
    let sl .= '%#StatusLineFileEncodingError# '.fileEncoding.' %*'
  endif
  " }}}

  " Right / Left separator {{{
  let sl .= '%<' " Cut statusline here if not enough room
  let sl .= '%=' " Add whitespace to align next part on the right
  " }}}
  "
  " Debug var {{{
  let sl .= '%{exists("b:o_debug") ? "B[".b:o_debug."] " : ""}'
  let sl .= '%{exists("g:o_debug") ? "G[".g:o_debug."] " : ""}'
  " }}}

  " Filetype {{{
  let b:filetypeStatusLine = FiletypeStatusLine()
  if b:filetypeStatusLine !=# ''
    let sl .= b:filetypeStatusLine.' '
  endif
  " }}}

  " Foldmarker {{{

  let foldMarker = '?'
  if &foldmethod ==# 'manual' | let foldMarker = 'M' | endif
  if &foldmethod ==# 'marker' | let foldMarker = '{' | endif
  if &foldmethod ==# 'syntax' | let foldMarker = 'S' | endif
  if &foldmethod ==# 'indent' | let foldMarker = '▸' | endif
  let sl .= ' '.foldMarker.' '
  " }}}

  " Ruler {{{
  let sl .= ' %2.c:%2.l %3p%% ' " current char
  let sl .= ' 0x%2.B' " current char
  " let sl .= ' %2.c/%2.{&textwidth}' " current colum / max columns
  " let sl .= ' %3l/%3L' " current line / max line
  " let sl .= ' %3p%%' " percentage in file
  " }}}


  return sl
endfunction

" Updating expensive status line variables only when moving through buffers or
" saving the file
augroup statusline_git
  autocmd!
	autocmd BufWritePost,BufEnter * call OroshiStatusLineUpdateGit()
augroup END
function! OroshiStatusLineUpdateGit()
  let b:statusLineGitStatus = GitFileStatus()
endfunction
