" DINGOOGBA
setlocal foldmethod=indent
" Must use Dos line endings
setlocal fileformat=dos
au BufNewFile,BufRead,BufWritePre <buffer> silent call ConvertLineEndingsToDos()
" Max 40 chars per line
setlocal textwidth=40

