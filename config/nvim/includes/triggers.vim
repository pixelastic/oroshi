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
" RELOAD COLORS {{{
" Reload colors whenever a color file is edited
augroup ft_colors_config
  autocmd!
  " Reload colors whenever we update them in kitty, tmux or zsh
  autocmd BufWritePost *config/kitty/colors.conf :silent !colors-refresh
  autocmd BufWritePost *config/tmux/colors.conf  :silent !colors-refresh
  autocmd BufWritePost *config/zsh/theming/src/* :silent !colors-refresh

  " Regenerate configs that uses ENV variables on save
  autocmd BufWritePost *config/bat/src/oroshi.xml :silent !~/.oroshi/config/bat/generate-theme
  autocmd BufWritePost *config/git/src/gitconfig :silent !~/.oroshi/config/git/generate-config
  autocmd BufWritePost *config/rg/src/rgrc.conf :silent !~/.oroshi/config/rg/generate-config

  " Whenever we change the way colors, filetypes or projects are defined, we need
  " to regenerate the ENV variables
  autocmd BufWritePost *scripts/bin/env-generate-colors :silent !colors-refresh
  autocmd BufWritePost *scripts/bin/env-generate-filetypes :silent !colors-refresh
  autocmd BufWritePost *scripts/bin/env-generate-projects :silent !colors-refresh
augroup END
" }}}
