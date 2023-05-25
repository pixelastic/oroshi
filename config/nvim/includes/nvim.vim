" nvim-specific configs

" We tell nvim where the python binary is, so it does not have to make expensive
" calls to the system
" Without it, any call to `has('python')` (as is often done in plugins) would
" result in a ~5s overhead
" let g:python3_host_prog='/home/tim/.pyenv/shims/python'
let g:python_host_prog='/home/tim/.pyenv/shims/python'
