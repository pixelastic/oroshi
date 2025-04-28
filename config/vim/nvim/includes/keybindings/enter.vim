" ENTER KEY

" [Enter]
" Add line after this one
nnoremap <CR> mzo<Esc>`z

" [Shift-Enter] Add new line before
nnoremap <S-CR> mzO<Esc>d$`z
inoremap <S-CR> <Esc>lmzO<Esc>d$`zi
