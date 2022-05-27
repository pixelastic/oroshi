" YAML
" Indentation rules {{{
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab
" setlocal equalprg=prettier -
" }}}
" Syntastic {{{
let g:syntastic_yaml_checkers = ['yamllint']
"}}}
" Cleaning {{{
inoremap <silent> <buffer> <F4> <Esc>:call YamlBeautify()<CR><CR>
nnoremap <silent> <buffer> <F4> :call YamlBeautify()<CR><CR>
function! YamlBeautify() 
  let l:initialLine = line('.')
  execute '%!prettier --stdin --parser yaml'
  execute 'normal '.initialLine.'gg'
  SyntasticCheck()
endfunction
" }}}
