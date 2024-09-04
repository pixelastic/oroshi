" Helper function to find the filetypeKey of a given filepath
" Note: Can be used to find the right icon with
" execute 'let icon=$FILETYPE_' . filetypeKey . '_ICON'
" Usage:
" FiletypeKey('/path/to/file.js')      # Returns JS
" FiletypeKey('/path/to/script')       # Returns ZSH
function! FiletypeKey(fullPath)
  let extension = fnamemodify(a:fullPath, ':e')
  let filetypeKey = toupper(extension)

  " Let's consider executable files without extensions as ZSH files
  if filetypeKey ==# '' && executable(a:fullPath)
    let filetypeKey = 'ZSH'
  endif

  return filetypeKey
endfunction
