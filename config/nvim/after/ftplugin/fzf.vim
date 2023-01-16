" FZF windows
" Disable statusline when opening a fzf buffer
setlocal laststatus=0
setlocal noshowmode
setlocal noruler

" And re-enabling it when leaving it
augroup ftplugin_fzf
  autocmd!
  autocmd BufLeave <buffer> set laststatus=2 showmode ruler
augroup END
" }}}

