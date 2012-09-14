" TXT
" Force txt to fit in 79 columns
setlocal formatoptions+=t
" Allow folding with marker
setlocal foldmethod=marker
setlocal commentstring=\ %s
" Force line ending to Unix
silent call ConvertLineEndingsToUnix()
" Clean Windows special chars
silent call ConvertWindowsCharacters()

