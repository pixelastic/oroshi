" RUBY
" Easy string interpolation with ##
inoremap ## #{}<Left>
" Enable Omnicompletion
setlocal omnifunc=rubycomplete#Complete
" Add string interpolation surround with #
let b:surround_35 = "#{\r}"
" Fix common typo
inoremap elseif elsif
" I still need that for a while, coming from PHP
inoremap echo puts
