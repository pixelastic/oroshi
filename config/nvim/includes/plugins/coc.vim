let g:coc_global_extensions = [
  \ 'coc-eslint',
  \ 'coc-prettier',
  \ 'coc-html',
  \ 'coc-json',
  \ 'coc-tsserver'
  \ ]

" set updatetime=300

" " This should reduce the blocking of vim on first inspection
" set shortmess+=c

" " Go to definition
" " TODO: Should open in new tab, not replace current one
" nmap <silent> gd <Plug>(coc-definition)

" " Show documentation
" nnoremap <silent> <F1> :call <SID>show_documentation()<CR>

" function! s:show_documentation()
"   if (index(['vim','help'], &filetype) >= 0)
"     execute 'h '.expand('<cword>')
"   elseif (coc#rpc#ready())
"     call CocActionAsync('doHover')
"   else
"     execute '!' . &keywordprg . " " . expand('<cword>')
"   endif
" endfunction

" " Error floating window can stay and create ghost artefacts when switching tabs
" " We force removing them when entering a buffer
" augroup coc_ghost_floats
"   autocmd!
"   autocmd BufEnter * call coc#float#close_all()
" augroup END

" " Remove some languages from Syntastic as they are handled by Coc
" let syntastic_filetypes = g:syntastic_mode_map.active_filetypes
" call remove(syntastic_filetypes, index(syntastic_filetypes, 'javascript'))
" call remove(syntastic_filetypes, index(syntastic_filetypes, 'json'))
