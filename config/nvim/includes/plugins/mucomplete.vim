" MUComplete does chained completion
" Checks in one bucket of completion, if can't find it in the next one and so on
" https://github.com/lifepillar/vim-mucomplete

" Disable default mapping, as we already have [Ctrl-H] mapped to previous tab
" We'll remap them manually (check in keybindings/*.vim)
let g:mucomplete#no_mappings='1'
