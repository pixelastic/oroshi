" Display colored information about the current filetype
  " TODO: Use icons for filtypes
  " TODO: Use filetype colors
  " let sl .= ' '.&filetype.' '
  " let sl .= "$FILETYPES[.css,icon]"

" Returns a string representation of the filetype
" - Colored based on colors in filetypes-list.zsh
" - With an icon matching the extension
" - With the filetype as detected by vim if different
function! FiletypeStatusLine()
  let extension=expand('%:e')
  let filetype_index= toupper(extension)

  " vint: -ProhibitUsingUndeclaredVariable
  execute 'let icon=$FILETYPES_' . filetype_index . '_ICON'
  execute 'let color=$FILETYPES_' . filetype_index . '_COLOR'

  let filetypeStatus=''
  let filetypeStatus.='%#RawColor2#'
  let filetypeStatus.=icon
  let filetypeStatus.=extension
  let filetypeStatus.=' %*'

  " vint: +ProhibitUsingUndeclaredVariable
  return filetypeStatus

  return extension

  let filepath = expand('%:p:h:t').'/'.expand('%:t')
  return '{}kjkj'
endfunction
