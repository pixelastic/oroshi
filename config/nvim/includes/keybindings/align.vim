" Align elements, using the EasyAlign plugin
" https://github.com/junegunn/vim-easy-align
"
" ga<Space> aligns on spaces
vnoremap ga<Space> <Plug>(EasyAlign)*<Space>
" ga| aligns on pipes
vnoremap ga\| :EasyAlign * /\|/<CR>
" ga# aligns on hashes
vnoremap ga# :EasyAlign * #<CR>
" ga= aligns on equal signs
vnoremap ga= :EasyAlign * =<CR>
