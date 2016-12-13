" dockerfile
" All Dockerfile.* files are to be interpreted as Dockerfile
augroup ftdetect_dockerfile
  autocmd!
  autocmd BufRead,BufNewFile *Dockerfile.* set filetype=dockerfile
augroup END
