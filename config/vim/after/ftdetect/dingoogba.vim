" DINGOO GBA
" Note: This are text files the GBA emulator on the Dingoo A320 can read
" Note: It IS important to keep txt.dingoogba and not dingoogba.txt
augroup ftdetect_dingoogba
  autocmd!
  autocmd BufRead,BufNewFile *games/gba/*.txt set filetype=txt.dingoogba
augroup END
