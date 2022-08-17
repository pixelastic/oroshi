" EXECUTABLE FILES {{{
" Set chmod +x on files starting with a shebang
augroup ft_add_chmodx
  autocmd!
  function! AddExecutablePermissionIfScript()
    if getline(1) =~? '^#!' && getline(1) =~? '/bin/'
      silent !chmod +x <afile>
    endif
  endfunction
  autocmd BufWritePost * call AddExecutablePermissionIfScript()
augroup END
" }}}
" RELOAD NVIM CONFIG {{{
" Reload the vimrc file whenever it is edited
augroup ft_nvim_config
  autocmd!
  autocmd BufWritePost *config/nvim mkview | source ~/.config/nvim/init.vim | loadview
augroup END
" }}}
