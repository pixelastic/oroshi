" Delete the current file from disk, and close its tab
function! DeleteCurrentFile(...)
  let currentFilepath = expand('%:p')

  " No such file
  if !filereadable(currentFilepath)
    echoerr '✘ '.currentFilepath.' does not exists'
    return
  endif

  let isDeleted = delete(currentFilepath)
  if isDeleted != 0
    echoerr '✘ Error while deleting '.currentFilepath
  endif

  echo '✔ ' . currentFilepath . ' deleted'

  " Closing all opened buffers of this file
  call CloseBufferByFilepath(currentFilepath)
endfunction
command! -complete=file -nargs=* Delete call DeleteCurrentFile()
