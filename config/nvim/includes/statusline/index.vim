" STATUS LINE
source ~/.vim/includes/statusline/git.vim
source ~/.vim/includes/statusline/lint.vim

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
let b:gitStatus = ''

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
  let sl .= '%#StatusLineMode'.modeName.'Separator#%* '
  " }}}
  "
  
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
	if exists('b:gitStatus') && b:gitStatus !=# ''
    let sl .= '%#StatusLineGit'.b:gitStatus.'#ﰖ%* '
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
  let sl .= '%='
  let sl .= '%#StatusLineRight#'
  " }}}
  "
  " Lint status {{{
  let b:lintStatusLine = LintStatusLine()
  if b:lintStatusLine !=# ''
    let sl .= b:lintStatusLine.' '
  endif
  " }}}

  " Debug var {{{
  let sl .= '%{exists("b:o_debug") ? "B[".b:o_debug."] " : ""}'
  let sl .= '%{exists("g:o_debug") ? "G[".g:o_debug."] " : ""}'
  " }}}

  " Filetype {{{
  let sl .= ' '.&filetype.' '
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
  let sl .= ' '
  let sl .= '0x%2.B' " current char
  let sl .= ' %2.c/%2.{&textwidth}' " current colum / max columns
  let sl .= ' %3l/%3L' " current line / max line
  let sl .= ' %3p%%' " percentage in file
  " }}}
  let sl .= '%*'


  return sl
endfunction

" Updating expensive status line variables only when moving through buffers or
" saving the file
augroup git_statusline
  au!
	au BufWritePost,BufEnter * call OroshiStatusLineUpdateGit()
augroup END

function! OroshiStatusLineUpdateGit()
  let b:gitStatus = GitFileStatus()
endfunction
