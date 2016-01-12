" RUBY
" Keybindings {{{
" describe, before(:each) and it
" Note: I had to hack with mz/'z otherwise by cursor was jumping around
inoremap <buffer> dsc describe '' doendmz'zkf'li
inoremap <buffer> bfe before(:each) doendO
inoremap <buffer> iit it '' doendklli
" }}}
" Indentation {{{
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab
" }}}
" #{} interpolation {{{
inoremap <buffer> ## #{}<Left>
let b:surround_35 = "#{\r}"
" }}}
" Helpers {{{
inoremap <buffer> Fep File.expand_path(
inoremap <buffer> Fbn File.basename(
inoremap <buffer> Fdn File.dirname(
inoremap <buffer> Fen File.extname(
" }}}
" Folds {{{
setlocal foldmethod=syntax
" }}}
" Linters {{{
let b:syntastic_checkers = ['rubocop', 'mri']
" }}}
" Cleaning the file {{{
inoremap <silent> <buffer> <F4> <Esc>:call RubyBeautify()<CR>
nnoremap <silent> <buffer> <F4> :call RubyBeautify()<CR>
function! RubyBeautify() 
  let linenr=line('.')
  echo '  Rubocop auto-correct...'
  let current_file = expand('%:p')
	silent! execute '%!ruby-lint ' . current_file
  echo ''
  execute 'normal '.linenr.'gg'
endfunction
" }}}
" Misc {{{
setlocal omnifunc=rubycomplete#Complete
" Note: It seems that simply doing `setlocal iskeyword-=_` does not actually
" remove the _
setlocal iskeyword=@,48-57,192-255,-,#
" }}}

