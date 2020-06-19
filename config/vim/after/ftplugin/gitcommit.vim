" GITCOMMIT
" When writing a commit message {{{
if expand('%') =~ 'COMMIT_EDITMSG'
  let b:onBufEnterFired = 0
  " Add possible convention types {{{
  augroup gitcommit_BufEnter
    autocmd!
    au BufEnter <buffer> call GitCommitOnBufEnter()
  augroup END
  " We need to delay the call a bit, so we use BufEnter. We also take care to
  " only fire it once because each time we move into split windows, it will
  " fire it again (and we use split windows with committia).
  function! GitCommitOnBufEnter() 
    if b:onBufEnterFired ==# 1
      return
    endif
    let b:onBufEnterFired = 1

    " Add reminder of convention types
    normal! ggo# 
    normal! APossible types : feat, fix, dev, test, refactor, docs, chore
    normal! xo# BREAKING CHANGE:
    normal! x
    normal! gg

    " Set smaller column
    setlocal colorcolumn=71
    setlocal textwidth=70
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
