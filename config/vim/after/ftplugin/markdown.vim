" MARKDOWN

" Styling {{{
" Add headers with ,(1|2|3|4|5)
nnoremap <buffer> <leader>& I# <Esc>j
nnoremap <buffer> <leader>é I## <Esc>j
nnoremap <buffer> <leader>" I### <Esc>j
nnoremap <buffer> <leader>' I#### <Esc>j
nnoremap <buffer> <leader>( I##### <Esc>j
" `Code`
vnoremap <buffer> ` <Esc>mzg`>a`<Esc>g`<i`<Esc>`zl
" _Italic_
vnoremap <buffer> _ <Esc>mzg`>a_<Esc>g`<i_<Esc>`zl
" **Bold**
vnoremap <buffer> * <Esc>mzg`>a**<Esc>g`<i**<Esc>`zl
" }}}
" Folding {{{
function! MarkdownLevel()
  let currentLine = getline(v:lnum)
  let headerMarker = matchstr(currentLine, '^#\+')
  let headerLevel = len(headerMarker)

  if headerLevel > 0
    return ">".headerLevel
  endif

  return "="
endfunction
setlocal foldexpr=MarkdownLevel()  
setlocal foldmethod=expr  
" }}}
" Running the file in the browser {{{
nnoremap <silent> <buffer> <F5> :call MarkdownConvertAndRun()<CR>
function! MarkdownConvertAndRun()
  let thisFile = shellescape(expand('%:p'))
  let htmlFile = '/tmp/vim-generated-markdown.html'
  " Create the html file
  silent execute '!markdown ' . thisFile . ' > ' . shellescape(htmlFile)
  " Run it
  call OpenUrlInBrowser(htmlFile)
endfunction
" }}}
" Wrapping {{{
" Auto-wrap text
setlocal formatoptions+=t
" }}}
" Keybindings {{{
" Add current copy-paste buffer to link on word
nnoremap <buffer> ]] "zciw[<Esc>"zpi<Right>](<Esc>"*pi<Right>)<Esc>mzvipgq`z
vnoremap <buffer> ]] "zc[<Esc>"zpli](<Esc>"*pli)<Esc>mzvipgq`z
" }}}
" Cleaning the file {{{
inoremap <silent> <buffer> <F4> <Esc>:call MarkdownBeautify()<CR>
nnoremap <silent> <buffer> <F4> :call MarkdownBeautify()<CR>
function! MarkdownBeautify() 
  let linenr=line('.')
  " Convert links into references
  silent! %! formd -r
  silent! %s///e
  " Remove bad chars after copy-paste
  silent! %s/’/'/e
  silent! %s/‘/'/e
  " Fix common typos/errors
  silent! %s/\<requete/requête/e
  silent! %s/\<plutot\>/plutôt/e
  silent! %s/\<fenetre/fenêtre/e
  silent! %s/\<interessant/intéressant/e
  silent! %s/\<accelerer\>/accélérer/e
  silent! %s/\<interet/intérêt/e
  silent! %s/\<entete/entête/e
  silent! %s/\<tres\>/très/e
  silent! %s/\<trés\>/très/e
  silent! %s/\<etre\>/être/e
  silent! %s/\<coute\>/coûte/e

  execute 'normal '.linenr.'gg'
endfunction
" }}}
" Auto generate index.html when in a remark directory {{{
let b:currentFile = expand('%:h')
let b:generateScript = expand('%:p:h').'/generate'
if b:currentFile == 'slides.md' && filereadable(b:generateScript)
  augroup markdown_generate_remark
    au!
    au BufWritePost <buffer> silent! execute '!'.b:generateScript
  augroup END
endif
" }}}
" Spellchecking {{{
setlocal spelllang=en
" Change language and/or toggle
nnoremap <buffer> se :setlocal spelllang=en<CR>
nnoremap <buffer> sf :setlocal spelllang=fr<CR>
nnoremap <buffer> <F6> :setlocal spell!<CR>
inoremap <buffer> <F6> <Esc>:setlocal spell!<CR>i
" Next/Previous error
nnoremap <buffer> sj ]s
nnoremap <buffer> sk [s
" Add/Remove from dictionary
nnoremap <buffer> sa zg]s
nnoremap <buffer> sr zug
" Suggest correction
nnoremap <buffer> ss ei<Right><C-X>s<C-N>
" Set in french for some known locations
if expand('%:p') =~ 'meetups.pixelastic.com/app/'
  setlocal spelllang=fr
endif
" }}}
