" [CTRL-O] and [CTRL-SHIFT-O] move in jump history
" Note: CTRL-O is a default vim binding to allow to jump to previous positions
" in the jumplist. It unfortunately changes the current buffer to where it
" jumps, and as I am using tabs in vim, it makes me lose the context of the file
" I was in. Instead, I want it to open a new tab (or re-use an existing one) if
" jumping to another file.
function! JumpToPrevious()
  echom "------------"
  messages clear
  let jumpList = OroshiJumpList()
  let index = OroshiJumpIndex(jumpList)
  if index ==# 0
    echom "No more jumps"
    return
  endif
  let previousJumpRaw = jumpList[index - 1]
  let previousJump = OroshiJumpDetails(previousJumpRaw)
  let jumpFile = previousJump.filepath
  let currentFile = expand('%:p')

  echom "Jump Raw: ".previousJumpRaw
  echom "Jump: "
  echom previousJump

  " If in same file, we jump
  if jumpFile ==# currentFile
    echom "Same file"
    execute "normal! \<C-o>"
    return
  endif

  let tabIndex = OroshiJumpTabIndex(jumpFile)

  " We open a new tab and jump there if it isn't yet edited
  if !tabIndex
    echom "New file"
    execute 'keepjumps tabe'
    execute "normal! \<C-o>"
    return
  endif

  " We move to the already edited tab
  echom "Existing file"
  execute tabIndex.'tabnext'

  let newTabJumpList = OroshiJumpList()
  let jumpLine = previousJump.line
  let jumpColumn = previousJump.column
  let jumpNumber = OroshiJumpFindNumber(newTabJumpList, jumpFile, jumpLine, jumpColumn)
  execute "normal! ".jumpNumber."\<C-o>"
endfunction

nnoremap <C-O> :call JumpToPrevious()<CR>
" nnoremap <silent> Ⓘ :call JumpToNext()<CR>
"
function! OroshiJumpList()
  redir => l:output
  silent! jumps
  redir END
  redraw  " This is necessary because of the :redir done earlier.

  return split(l:output, "\n")[1:] " The first line contains the header.
endfunction

function! OroshiJumpIndex(jumpList)
  for l:index in reverse(range(len(a:jumpList)))
    if a:jumpList[l:index][0] ==# '>'
      break
    endif
  endfor
  return l:index
endfunction

function! OroshiJumpDetails(jumpLine)
  let l:parseResult = matchlist(a:jumpLine, '^>\?\s*\(\d\+\)\s\+\(\d\+\)\s\+\(\d\+\)\s\+\(.*\)$')
  let l:number = get(l:parseResult, 1, 0)
  let l:line   = get(l:parseResult, 2, 0)
  let l:column = get(l:parseResult, 3, 0)
  let l:text   = get(l:parseResult, 4, '')

  let l:filepath = OroshiJumpFilepath(l:text, l:line)

  return {
  \  'number':   l:number,
  \  'line':     l:line,
  \  'column':   l:column,
  \  'filepath': l:filepath,
  \}
endfunction

function! OroshiJumpFilepath(jumpText, jumpLine)
  " We compare the text with the text in the current file on the given line
  " If they are the same, then we're on the current file
  " Otherwise, we are on the file indicated by the text

  let currentFile = expand('%:p')
  let rawLineInCurrentFile = getline(a:jumpLine)
  let formattedLineInCurrentFile = trim(rawLineInCurrentFile)
  echom "jumptext: [".a:jumpText."]"
  echom "comparison: [".formattedLineInCurrentFile."]"

  " If jump text is the same as what we have in the current file, the target is
  " the current path
  if a:jumpText ==# formattedLineInCurrentFile
    return currentFile
  endif

  " Otherwise, the target is the filepath written in the text
  return expand(a:jumpText)
endfunction

" Returns the tabIndex of a given filepath
function! OroshiJumpTabIndex(filepath)
  for tabIndex in range(1, tabpagenr('$'))
    " We assume each tab only has one window
    let windowId = win_getid(1, tabIndex)
    let bufferIndex = winbufnr(windowId)
    let bufferFile = expand('#' . bufferIndex .':p')
    if bufferFile ==# a:filepath
      return tabIndex
    endif
  endfor
  return 0
endfunction

" Return the jump object that matches the filepath, line and column passed
function! OroshiJumpFindNumber(jumpList, filepath, line, column)
  for index in reverse(range(len(a:jumpList)))
    let jump = OroshiJumpDetails(a:jumpList[index])
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
  return 0
endfunction

"function! EnhancedJumps#Common#ParseJumpLine( jumpLine )
"endfunction


"" Take either the previous or the next
"function! EnhancedJumps#Common#SliceJumpsInDirection( jumps, isNewer )
""******************************************************************************
""* PURPOSE:
""   From the list of jumps, keep only those following the current index in the
""   direction of jump, and reverse older jumps so that the jump index directly
""   corresponds to the count of the jump.
""* ASSUMPTIONS / PRECONDITIONS:
""   None.
""* EFFECTS / POSTCONDITIONS:
""   None.
""* INPUTS:
""   a:jumps List of jump lines from :jumps or :changes command.
""   a:isNewer	Flag whether the jump is to newer jumps.
""* RETURN VALUES:
""   Rearranged slice of jumps; the jump index corresponds to the jump count.
""******************************************************************************
"    let l:currentIndex = s:GetCurrentIndex(a:jumps)
"    if a:isNewer
"	return a:jumps[(l:currentIndex + 1) : ]
"    else
"	return (l:currentIndex == 0 ? [] : reverse(a:jumps[ : (l:currentIndex - 1)]))
"    endif
"endfunction





"" Failsafe if invalid
"function! EnhancedJumps#Common#IsInvalid( text )
"    if a:text ==# '-invalid-'
"	" Though invalid jumps are caused by marks in another (modified) file,
"	" treat them as belonging to the current buffer; after all, Vim doesn't
"	" move to that file, and just prints the "E19: Mark has invalid line
"	" number" error.
"	return 1
"    endif
"endfunction


"" Check if in current buffer or not
"function! EnhancedJumps#Common#IsJumpInCurrentBuffer( parsedJump )
"    if empty(a:parsedJump.text)
"	" In case there is no jump text, the corresponding line in the current
"	" buffer also should be empty.
"	let l:regexp = '^$'
"    else
"	" The jump text omits any indent, may be truncated and has non-printable
"	" characters rendered as ^X (so any ^X substring may either represent a
"	" non-printable single character or the literal two-character ^X
"	" sequence). The regexp has to consider this.
"	let l:regexp = '\V' . substitute(escape(a:parsedJump.text, '\'), '\^\%(\\\\\|\p\)', '\\%(\0\\|\\.\\)', 'g')
"    endif
""****D echomsg '****' l:regexp
"    return getline(a:parsedJump.lnum) =~# l:regexp
"endfunction
