"! DINGOOGBA
setlocal foldmethod=indent
" Must use Dos line endings
setlocal fileformat=dos
augroup ftplugin_dingoogba
  autocmd!
  autocmd BufNewFile,BufRead,BufWritePre <buffer> silent call ConvertLineEndingsToDos()
augroup END
" Max 40 chars per line
setlocal textwidth=40
