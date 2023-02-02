function! StrDebug(str)
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
endfunction
