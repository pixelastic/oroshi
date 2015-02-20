" GITCOMMIT

" When writing a commit message {{{
if expand('%')=='COMMIT_EDITMSG'
  " Add possible types {{{
  augroup gitcommit_BufEnter
    autocmd!
    au BufEnter <buffer> call GitCommitOnBufEnter()
  augroup END
  function! GitCommitOnBufEnter() 
    let @x='# Possible types : chore, docs, feat, fix, perf, refactor, style, test'
    normal 1gg
    put x
    normal gg
  endfunction
  " }}}
  " Save commit {{{
  nnoremap <buffer> <C-S> :x<CR>
  inoremap <buffer> <C-S> <Esc>:x<CR>
  " }}}
  " Discard commit {{{
    nnoremap <buffer> <C-D> :cq!<CR>
    inoremap <buffer> <C-D> <Esc>:cq!<CR>
  " }}}
endif
" }}}
" When viewing the list of changes with fugitive {{{
if expand('%')=='index'
  " Close window {{{
  nnoremap <buffer> <C-S> :x<CR>
  inoremap <buffer> <C-S> <Esc>:x<CR>
  nnoremap <buffer> <C-D> :x<CR>
  inoremap <buffer> <C-D> <Esc>:x<CR>
  " }}}
endif
" }}}
