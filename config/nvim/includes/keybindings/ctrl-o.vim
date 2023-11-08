" [CTRL-O] and [CTRL-SHIFT-O] move in jump history
" Note: CTRL-O is a default vim binding to jump to previous positions in the
" jumplist. It unfortunately changes the current buffer to where it jumps, and
" as I am using one buffer per tab, it makes me lose the context of the file
" I was in.
" Instead, I want it to open a new tab (or re-use an existing one) if
" jumping to another file. This requires manually parsing the :jumplist and
" doing a few hacks to keep the jump context when creating/switching tabs
" TODO: Ctrl-Shift-O does work consistently. If moving backward to another
" filer, then forward you do not always come back to the original file as each
" window has its own jumplist.
function! OroshiJump(increment)
  let upcomingJump = OroshiJump_Upcoming(a:increment)
  if type(upcomingJump) == v:t_number && upcomingJump ==# 0
    echom 'No more jumps'
    return
  endif

  " The command to pass is Ctrl-O to move backward and Ctrl-I to move forward
  let jumpKeys = a:increment < 0 ? "\<C-o>" : "\<C-i>"

  " We now have three possible outcomes:
  " 1. The jump is in the same file
  "   => We use the regular <C-O> behavior
  " 2. The jump is in another file we've never opened before
  "   => We open an empty tab
  "   => We use the regular <C-O> behavior to fill it with the jump buffer
  " 3. The jump is in another file, and we already have it opened
  "   => We switch to the tab that has it opened
  "   => We find the same jump in this tab jumplist and jump to it
  let jumpFile = upcomingJump.filepath

  " 1. Jump in the same file
  let currentFile = expand('%:p')
  if jumpFile ==# currentFile
    " echo 'same file'
    execute 'normal! 1'.jumpKeys
    return
  endif

  " 2. Jump in a new file
  let tabNumber = OroshiJump_TabNumberFromFilepath(jumpFile)
  if !tabNumber
    " echo 'new file'
    execute 'keepjumps tabe'
    execute 'normal! 1'.jumpKeys
    return
  endif

  " 3. Jump in an existing file
  " echo 'existing file'
  execute ''.tabNumber.'tabnext'

  let newTabJumpList = OroshiJump_RawList()
  let jumpLine = upcomingJump.line
  let jumpColumn = upcomingJump.column
  let jumpNumber = OroshiJump_FindNumber(newTabJumpList, jumpFile, jumpLine, jumpColumn)
  execute 'normal! '.jumpNumber.''.jumpKeys

endfunction

nnoremap <silent> <C-O> :call OroshiJump(-1)<CR>
nnoremap <silent> Ⓞ :call OroshiJump(1)<CR>

" Returns an array of all raw entries in the jumplist
function! OroshiJump_RawList() " {{{
  " vim doesn't have a method to get this list, so we'll catch the output of the
  " command in a variable instead
  redir => l:output
    silent! jumps
  redir END
  redraw

  " Cast as an array and remove the header line
  return split(l:output, "\n")[1:]
endfunction
" }}}

" Return the upcoming jump as an object with filepath, line, column and number.
" The direction can be defined with 1 or -1 as argument.
function! OroshiJump_Upcoming(increment) " {{{
  let jumpList = OroshiJump_RawList()
  let jumpListSize = len(jumpList)

  " Find the entry that starts with ">"
  let currentJumpIndex = -1
  for l:index in reverse(range(jumpListSize))
    if jumpList[l:index][0] ==# '>'
      let currentJumpIndex = l:index
      break
    endif
  endfor

  " Can't find upcoming jump
  let upcomingJumpIndex = currentJumpIndex + a:increment
  if upcomingJumpIndex < 0 || upcomingJumpIndex > jumpListSize - 1
    return 0
  endif

  return OroshiJump_Parse(jumpList[upcomingJumpIndex])
endfunction
" }}}

" Parse a raw jumplist line into an object with filepath, line, column and
" number
function! OroshiJump_Parse(jumpLine) " {{{
  let l:parseResult = matchlist(a:jumpLine, '^>\?\s*\(\d\+\)\s\+\(\d\+\)\s\+\(\d\+\)\s\+\(.*\)$')
  let l:number = get(l:parseResult, 1, 0)
  let l:line   = get(l:parseResult, 2, 0)
  let l:column = get(l:parseResult, 3, 0)
  let l:text   = get(l:parseResult, 4, '')

  let l:filepath = OroshiJump_Filepath(l:text, l:line)

  return {
  \  'filepath': l:filepath,
  \  'line':     l:line,
  \  'column':   l:column,
  \  'number':   l:number,
  \}
endfunction
" }}}

" Given a jump text and line, we'll return the filepath it refers to
function! OroshiJump_Filepath(jumpText, jumpLine) " {{{
  " Note: Jumplist text contain either the filepath if it's in another file, or
  " the content of the line if it's in the same file. We have no other way to
  " distinguish them than testing if the line in the current file matches the
  " jump text
  " Note: We can have a (highly improbable) false positive if the line in the
  " current file actually contains the real filepath to the jump
  let currentFile = expand('%:p')

  " Text of the raw jump is a simplified version of the actual content of the
  " line, so we need to perform the same simplification before comparing them:
  " - Any starting whitespace is excluded
  " - Any special character (like ^I) is displayed as a literal ^I
  let rawLineInCurrentFile = getline(a:jumpLine)
  let formattedLineInCurrentFile = trim(rawLineInCurrentFile)
  let formattedLineInCurrentFile = substitute(formattedLineInCurrentFile, '\t', '^I' , 'g')
  let formattedLineInCurrentFile = substitute(formattedLineInCurrentFile, '\r', '^M' , 'g')


  " We compare our current line in this file with a regexp of the jump text. If
  " it matches, then the jump is in the current file.
  " Regexp-shenanigans to take into account:
  " - Jump text can be truncated, so we only compare to the start of the line
  " - Jump text can contain regexp-special characters, so we need to escape them
  let regexp = '^'.escape(a:jumpText, '\')
  if formattedLineInCurrentFile =~# regexp
    return currentFile
  endif

  " Otherwise, the target is the filepath written in the text
  " We still need to sanitize the filepath as it can be relative, or include ~
  let filepath = expand(a:jumpText)
  if filepath[0] !=# '/'
    let filepath = getcwd() . '/' . filepath
  endif
  return filepath
endfunction
" }}}

" Returns the tab number currently displaying the specified file
function! OroshiJump_TabNumberFromFilepath(filepath) " {{{
  " Note: I don't use splits in vim, so it is safe to assume that the first
  " window (split) of each tab contains the file to edit

  " We loop through tabs to check the file edited in the first window of each
  " tab. If it's the file we're looking for, we return the tab number
  for tabNumber in range(1, tabpagenr('$'))
    let bufferIndex = winbufnr(win_getid(1, tabNumber))
    let bufferFile = expand('#' . bufferIndex .':p')
    if bufferFile ==# a:filepath
      return tabNumber
    endif
  endfor

  " Couldn't find the file
  return 0
endfunction
" }}}

" Given a raw jumplist and a filter made of filepath, line and column, returns
" the number of the matching jump
function! OroshiJump_FindNumber(jumpList, filepath, line, column) " {{{
  " Note: Jumplist numbering is relative to the window it's part of. Even if two
  " windows have the same jumplist, the same jump won't have the same number.

  " We will loop through each entry in the raw jump list, and check if it
  " matches the filepath, line and column provided. If it does, we return its
  " number.
  for index in reverse(range(len(a:jumpList)))
    let jump = OroshiJump_Parse(a:jumpList[index])
    if jump.filepath !=# a:filepath
      continue
    endif
    if jump.line !=# a:line
      continue
    endif
    if jump.column !=# a:column
      continue
    endif

    return jump.number
  endfor

  " Couldn'd find a match
  return 0
endfunction
