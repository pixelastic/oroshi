" Helper function to find the filetypeKey of a given filepath
" Note: Can be used to find the right icon with
" execute 'let icon=$FILETYPE_' . filetypeKey . '_ICON'
" Usage:
" FiletypeKey('/path/to/file.js')      # Returns JS
" FiletypeKey('/path/to/script')       # Returns ZSH
function! FiletypeKey(fullPath)
  let extension = fnamemodify(a:fullPath, ':e')
  let filetypeKey = toupper(extension)

  " Let's define some filetypeKey for files without extension
  if filetypeKey ==# ''
    " zsh function or executable
    if a:fullPath =~# 'zsh/functions/autoload/' || a:fullPath =~# 'zsh/completion/compdef' || executable(a:fullPath)
      let filetypeKey = 'ZSH'
    endif
  endif

  " vint: -ProhibitUsingUndeclaredVariable
  " if the extension is unknown, we use the unknown type
  execute 'let filetypeGroup=$FILETYPE_' . filetypeKey . '_GROUP'
  if filetypeGroup ==# ''
    let filetypeKey='__UNKNOWN__'
  endif
  " vint: +ProhibitUsingUndeclaredVariable

  return filetypeKey
endfunction
