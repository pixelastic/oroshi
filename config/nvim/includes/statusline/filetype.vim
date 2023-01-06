" Display colored information about the current filetype

" Returns a string representation of the filetype
" - Colored based on colors in filetypes-list.zsh
" - With an icon matching the extension
" - With the filetype as detected by vim if different
function! FiletypeStatusLine()
  let extension=expand('%:e')
  let filetypeKey=toupper(extension)

  " vint: -ProhibitUsingUndeclaredVariable
  execute 'let icon=$FILETYPE_' . filetypeKey . '_ICON'
  let filetypeStatus=''
  let filetypeStatus.='%#Filetype_' . filetypeKey . '#'
  let filetypeStatus.=icon
  if &filetype !=# extension
    let filetypeStatus .=  ' ' . &filetype
  endif
  let filetypeStatus.='%*'
  " vint: +ProhibitUsingUndeclaredVariable

  return filetypeStatus
endfunction
