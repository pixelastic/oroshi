function! SeemsLatin1InUTF8(str)
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
