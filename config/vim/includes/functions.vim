scriptencoding utf-8
" Helpers
function! GetRepoRoot() " {{{
  " Use caching
  if exists('b:repoRoot')
    return b:repoRoot
  endif

  let workingDir = expand('%:h')

  " Check if git
  let gitRoot = system('cd '.workingDir.' && git rev-parse --show-toplevel')
  if gitRoot !~# '^fatal'
    let b:repoRoot = StrTrim(gitRoot)
    return b:repoRoot
  endif

  let b:repoRoot = workingDir
  return b:repoRoot
endfunction
" }}}
function! Debug(txt) " {{{
  " Display a var in the status line, for debug purposes
  let b:o_debug = a:txt
endfunction
command! -nargs=1 Debug call Debug(<q-args>)
" }}}
function! GDebug(txt) " {{{
  " Display a var in the status line, for debug purposes
  let g:o_debug = a:txt
endfunction
command! -nargs=1 GDebug call GDebug(<q-args>)
" }}}
function! StrDebug(str) " {{{
  let str=a:str
  let bytes=strlen(str)
  let length=strlen(substitute(str, '.', 'x', 'g'))
  echom ' '
  echom 'String: ['.str.']'
  echom 'Length: '.length
  echom 'Bytes:  '.bytes

  let i=0
  let r=''
  while i!=bytes
    let r.=char2nr(str[i]).' '
    let i+=1
  endwhile
  echom r
endfunction " }}}
function! CloseBufferByFilepath(filepath) " {{{
  let allBuffers = filter(range(1, bufnr('$')), 'buflisted(v:val)')
  for bufferIndex in allBuffers
    let bufferFilepath = fnamemodify(bufname(bufferIndex), ':p')
    if bufferFilepath ==# a:filepath
      execute 'bdelete! '.bufferIndex
    endif
  endfor
endfunction
" }}}

" String methods
function! StrTrim(txt) " {{{
  " Trim a string by removing starting and trailing whitespaces
  return substitute(a:txt, '^\n*\s*\(.\{-}\)\n*\s*$', '\1', '')
endfunction
" }}}
function! StrUncomment(txt) " {{{
  " Removes all comment and fold marker of a string
  let line = a:txt

  " Remove comments
  let comments = split(&commentstring, '%s')
  let comments[0] = escape(comments[0], '*')

  let line = substitute(line, '^\s*' . StrTrim(comments[0]), '', '')
  if len(comments) > 1
    let comments[1] = escape(comments[1], '*')
    let line = substitute(line, comments[1] . '$', '', '')
  endif

  " Remove folding marker
  if (&foldmethod ==# 'marker')
    let foldmarkers = split(&foldmarker, ',')
    let foldmarkers[0] = escape(foldmarkers[0], '*')

    let line = substitute(line, foldmarkers[0] . '.*$', '', '')

    " Remove trailing comment used to add the previously deleted foldmarker
    if strlen(StrTrim(comments[0])) > 1
      let line = substitute(line, comments[0] . '.*$', '', '')
    endif
  endif

  " Trim title
  let line = StrTrim(line)

  return line
endfunction
"}}}
function! StrLength(txt) " {{{
  " Return the number of chars in a string.
  " Note: This is different from strlen() as strlen() returns the number of
  " bytes, which is very different for utf-8 encoding.
  return strlen(substitute(a:txt, '.', 'x', 'g'))
endfunction " }}}
function! SeemsLatin1InUTF8(str) " {{{
  " Note: When a Windows-1252 (known as ISO-8859-1) is encoded in UTF-8, it
  " results in garbage (Ã© in place of é).
  " This method attempt to guess if the string given is such a wrongly decoded
  " string by checking for any four bytes in a row whose value is more than
  " 127.

  let i=0
  let c=0
  while i!=strlen(a:str)
    " Count high bytes
    if char2nr(a:str[i])>127
      let c+=1
    else
      let c=0
    endif
    " Enough high bytes to return true
    if c==4
      return 1
    endif

    let i+=1
  endwhile
  " Not enough high bytes
  return 0
endfunction " }}}
function! ShellEscapeForDoubleQuotes(filepath) " {{{
  " Returns an escaped filepath to be used in a system() call, wrapped in
  " double quotes
  return substitute(escape(a:filepath, '"'), "'", "''", 'g')
endfunction
" }}}

" Folding methods
function! IndentLevel(lnum) " {{{
  return indent(a:lnum) / &shiftwidth
endfunction
" }}}
function! NextNonBlankLine(lnum) " {{{
  let numlines = line('$')
  let current = a:lnum + 1

  while current <= numlines
    if getline(current) =~? '\v\S'
      return current
    endif

    let current += 1
  endwhile

  return -9999
endfunction
" }}}

" Commands
function! RemoveTrailingSpaces() " {{{
  normal! mz
  silent! %s/\s\+$//g
  nohl
  normal! `z
endfunction
command! RemoveTrailingSpaces call RemoveTrailingSpaces()
" }}}
function! IndentWithSpaces() " {{{
  normal! mz
  " Replace all tabs used for indentation with the same number of spaces
  silent! execute '%s/\v^\s+/\=substitute(submatch(0),"\t",repeat(" ", &tabstop),"g")'
  " Remove any leftover
  silent! execute '%s/\v^+/\=repeat(" ",len(submatch(0))-(len(submatch(0))%&tabstop))'
  nohl
  normal! `z
endfunction
command! IndentWithSpaces call IndentWithSpaces()
" }}}
function! IndentWithTabs() " {{{
  normal! mz
  " Indent first with spaces, then convert to tabs
  silent! call IndentWithSpaces()
  silent! execute '%s_\v^ +_\=repeat("\t",len(submatch(0))/&tabstop)'
  nohl
  normal! `z
endfunction
command! IndentWithTabs call IndentWithTabs()
" }}}
function! ConvertLineEndingsToUnix() " {{{
  if &modifiable==0 || expand('%') ==# '' || !filereadable(expand('%'))
    return
  endif
  update
  edit ++fileformat=dos
  execute '%s///ge'
  setlocal fileformat=unix
  write
endfunction
command! ConvertLineEndingsToUnix call ConvertLineEndingsToUnix()
" }}}
function! ConvertLineEndingsToDos() " {{{
  if &modifiable==0
    return
  endif
  setlocal fileformat=dos
endfunction
command! ConvertLineEndingsToDos call ConvertLineEndingsToDos()
" }}}
function! ConvertWindowsCharacters() " {{{
  " Note: To type a special char like <92> in vim, press <C-V>x92
  normal! mz
  silent! %s//'/
  silent! %s//"/
  silent! %s//"/
  silent! %s//.../
  nohl
  normal!`z
endfunction
command! ConvertWindowsCharacters call ConvertWindowsCharacters()
" }}}
function! ConvertToUTF8() " {{{
  set fileencoding=utf-8
endfunction
command! ConvertToUTF8 call ConvertToUTF8()
" }}}
function! FixEpub() " {{{
  " I often need to tweak epub files, so I convert them to txt and manually edit
  " them. This will help in doing most of the work
  
  normal! mz
  " Dialogs should use the em dash (–) and not the simple dash (-)
  silent! %s/\v^-/–/e
  " Use common guillemets
  silent! %s/“/"/e
  silent! %s/”/"/e
  silent! %s//"/e
  silent! %s//"/e
  " Same goes for apostrophes
  silent! %s/’/'/e
  silent! %s/‘/'/e
  silent! %s/`/'/e
  silent! %s//'/e
  " Fixing ". .." and ". . ."
  silent! %s/\v( ?)\. \.( ?)\./.../e
  silent! %s/…/.../e
  
  " Force space after dot and comma
  silent! %s/\v(\.|,)([^ "\.])/\1 \2/e
  " Force space after caps
  silent! %s/\v(\l)(\u)/\1 \2/e
  " Force space when case change inside a word
  silent! %s/\v(\u{2})(\l)/\1 \2/e
    
  " Fix new lines after a comma in dialogues.
  silent! %s/\v^— ((.*)[^\.!\?])\n\n([^—](.*))$/— \1 \3/e
  " Fix sentence cut in half with new lines
  silent! %s/\v(\l)(\n)+(\l)/\1 \3/e
  " Punctuation signs lost on new lines
  silent! %s/\v\n\n(\?|!|;|»)/ \1/e
  " French guillemets breaking sentences in new lines
  silent! %s/\v»\n\n(\U)/" \1/e

  " Setting the first line as the main title
  if getline(1) !~ '^\#'
    execute 'normal ggI# '
  endif
  " Putting each Chapter in caps
  silent! %s/\v^Chapter (.*)$/## CHAPTER \U\1/e
  " Using lines containing only a number as chapters
  silent! %s/\v^([0-9]+)$/## CHAPTER \1/e
  " Guessing titles by large number of empty lines around and short sentences
  " Note: Will have false positive on short lines.
  " silent! %s/\v\n{3,}(.{,50})\n*/\r\r## \1\r\r/e
  
  " Fix lines that only contain whitespace
  silent! %s/\s+$//e
  " Condensate multiple new lines into only one
  silent! %s/\v\n{3,}/\r\r/e

  " Marking each heading as a chapter
  " silent! %s/\v^([^#]{2}\L+)$/## \1/e
  nohl
  normal! `z
endfunction " }}}
function! DeleteFile(...) " {{{
  let specifiedFile = a:1

  " Default to current file if none selected
  if specifiedFile ==# ''
    let specifiedFile = expand('%:p')
  endif
  let specifiedFile = fnamemodify(specifiedFile, ':p')

  " No such file
  if !filereadable(specifiedFile)
    echoerr '✘ '.specifiedFile.' does not exists'
    return
  endif

  let isDeleted = delete(specifiedFile)
  if isDeleted == 0
    echo '✓ '.specifiedFile.' deleted'
  else
    echoerr '✘ Error while deleting '.specifiedFile
  endif

  " Closing all opened buffers of this file
  call CloseBufferByFilepath(specifiedFile)
endfunction
command! -complete=file -nargs=1 Delete call DeleteFile(<f-args>)
" }}}
