" RUBY
" Easy string interpolation with ##
inoremap <buffer> ## #{}<Left>
" Enable Omnicompletion
setlocal omnifunc=rubycomplete#Complete
" Add string interpolation surround with #
let b:surround_35 = "#{\r}"

" Easy typing
inoremap <buffer> Fep File.expand_path(
inoremap <buffer> Fbn File.basename(
inoremap <buffer> Fdn File.dirname(
inoremap <buffer> Fen File.extname(

" Use two spaces for indenting
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab
