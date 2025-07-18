" RUBY
" Syntax highlighting can be really slow on big ruby files. This seems to be
" cause by the new RegExp engine used by vim. So, for those files, we will
" revert to the previous engine
" http://stackoverflow.com/questions/16902317/vim-slow-with-ruby-syntax-highlighting
setlocal regexpengine=1
" Keybindings {{{
" describe, before(:each) and it
" Note: I had to hack with mz/'z otherwise by cursor was jumping around
inoremap <buffer> dsc describe '' doendmz'zkf'li
inoremap <buffer> ctx context '' doendmz'zkf'li
inoremap <buffer> ctw context '' doendmz'zkf'li
inoremap <buffer> bfd before doendO
inoremap <buffer> bff before {  }hi
inoremap <buffer> iit it '' doendklli
inoremap <buffer> IIT it {  }hi
inoremap <buffer> itst it { should eq true }o
inoremap <buffer> itsf it { should eq false }o
inoremap <buffer> itsn it { should eq nil }o
inoremap <buffer> sbj subject { current. }hi
inoremap <buffer> trc .to receive()i
inoremap <buffer> thrc .to have_received()i
inoremap <buffer> anrt .and_return()i
inoremap <buffer> bp binding.pry
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
" Cleaning the file {{{
inoremap <silent> <buffer> <F4> <Esc>:call RubyBeautify()<CR>
nnoremap <silent> <buffer> <F4> :call RubyBeautify()<CR>
function! RubyBeautify()
  let l:initialLine = line('.')
  execute 'silent w !rubocop -a % &>/dev/null'
  execute 'normal '.initialLine.'gg'
endfunction
" }}}
