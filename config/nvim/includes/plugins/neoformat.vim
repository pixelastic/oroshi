" Neoformat formats file
" https://github.com/sbdchd/neoformat
" It will not check for errors, but will simply format the content
"
" Note: Supported formatters:
" https://github.com/sbdchd/neoformat#supported-filetypes

let g:neoformat_basic_format_retab = 1 " Convert tabs to space
let g:neoformat_basic_format_trim = 1  " Trim trailing whitespaces

" I prefer to define explicitly what formatters are used. If not, it will depend
" on what is installed on the machine and is harder to debug.
let g:neoformat_enabled_json = ['prettier'] " json
let g:neoformat_enabled_yml = ['prettier']  " json
let g:neoformat_enabled_zsh = ['shfmt']     " zsh

let g:shfmt_opt='-ci' " Options for shfmt
