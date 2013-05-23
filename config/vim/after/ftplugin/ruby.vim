" RUBY
" Easy string interpolation with ##
inoremap ## #{}<Left>
" Enable Omnicompletion
setlocal omnifunc=rubycomplete#Complete
" Add string interpolation surround with #
let b:surround_35 = "#{\r}"

" Easy typing
inoremap Fep File.expand_path(
inoremap Fbn File.basename(
inoremap Fdn File.dirname(
inoremap Fen File.extname(

