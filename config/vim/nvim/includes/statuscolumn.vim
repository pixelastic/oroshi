" Status Column
" The way the left line column is displayed
" See: https://neovim.io/doc/user/options.html#'statuscolumn'
" Guide: https://www.reddit.com/r/neovim/comments/1djjc6q/statuscolumn_a_beginers_guide/

" TODO: Would be nice to keep the display minimal, only the line number, but
" change its color based on the git status
" Maybe check https://github.com/lewis6991/gitsigns.nvim instead of
" vim-gitgutter
let &statuscolumn='%s %l '
