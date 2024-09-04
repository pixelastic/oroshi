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
    if a:fullPath =~# 'zsh/functions/autoload/' || executable(a:fullPath)
      let filetypeKey = 'ZSH'
    endif
  endif

  return filetypeKey
endfunction
