" Display colored information about the current filetype

" Returns a string representation of the filetype
" - Colored based on colors in filetypes-list.zsh
" - With an icon matching the extension
" - With the filetype as detected by vim if different
function! FiletypeStatusLine()
  let fullPath=expand('%:p')
  let filetypeKey=FiletypeKey(fullPath)

  " vint: -ProhibitUsingUndeclaredVariable
  execute 'let icon=$FILETYPE_' . filetypeKey . '_ICON'
  let filetypeStatus = Colorize(&filetype . ' ' . icon, 'StatusLineFiletype_' . filetypeKey)
  " vint: +ProhibitUsingUndeclaredVariable

  return filetypeStatus
endfunction
