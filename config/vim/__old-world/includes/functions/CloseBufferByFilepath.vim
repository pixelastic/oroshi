" Close all tabs that hold a specific filepath
function! CloseBufferByFilepath(filepath)
  " Find all buffer ids
  let allBuffers = filter(range(1, bufnr('$')), 'buflisted(v:val)')

  " Iterate on them and check if they are focused on our file
  for bufferIndex in allBuffers
    let bufferFilepath = fnamemodify(bufname(bufferIndex), ':p')
    " Skip if not focused on our file
    if bufferFilepath !=# a:filepath
      continue
    endif
    " Deleting this buffer
    execute 'bwipeout! '.bufferIndex
  endfor

  " We now check to see if there is only one (empty) buffer opened
  " If so, we close vim
  let bufferInfo = getbufinfo({'buflisted':1})
  let bufferCount = len(bufferInfo)
  " There is only one buffer left
  if bufferCount ==# 1
    let bufferName = bufferInfo[0].name
    let bufferLineCount = bufferInfo[0].linecount
    " And it is unsaved and has only one line
    if bufferName ==# '' && bufferLineCount ==# 1
      exit
    endif
  endif
endfunction
