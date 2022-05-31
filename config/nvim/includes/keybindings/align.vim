" Align elements, using the EasyAlign plugin
" https://github.com/junegunn/vim-easy-align
"
" ga<Space> aligns on spaces
" This is clever enough to handle strings as one word, and ignores comments
xmap ga<Space> <Plug>(EasyAlign)*<Space>

" ga| aligns on pipes
vnoremap ga\| :EasyAlign * /\|/<CR>
