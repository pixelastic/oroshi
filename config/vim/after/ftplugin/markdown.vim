" MARKDOWN

" Styling {{{
" Add headers with ,(1|2|3|4|5)
nnoremap <buffer> <leader>& I# <Esc>j
nnoremap <buffer> <leader>é I## <Esc>j
nnoremap <buffer> <leader>" I### <Esc>j
nnoremap <buffer> <leader>' I#### <Esc>j
nnoremap <buffer> <leader>( I##### <Esc>j
" `Code`
nnoremap <buffer> <leader>c viw<Esc>g`>a`<Esc>g`<i`<Esc>
vnoremap <buffer> <leader>c <Esc>mzg`>a`<Esc>g`<i`<Esc>`zl
" _Italic_
nnoremap <buffer> <leader>i viw<Esc>g`>a_<Esc>g`<i_<Esc>
vnoremap <buffer> <leader>i <Esc>mzg`>a_<Esc>g`<i_<Esc>`zl
" **Bold**
nnoremap <buffer> <leader>b viw<Esc>g`>a**<Esc>g`<i**<Esc>
vnoremap <buffer> <leader>b <Esc>mzg`>a**<Esc>g`<i**<Esc>`zl
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
nnoremap <buffer> ]] bi[<Esc>eli](<Esc>"*pli)<Esc>mzvipgq`z
vnoremap <buffer> ]] "zc[<Esc>"zpli](<Esc>l"*pli)<Esc>mzvipgq`z
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
  silent! %s/requete/requête/e
  silent! %s/plutot/plutôt/e
  silent! %s/fenetre/fenêtre/e
  silent! %s/interessant/intéressant/e
  silent! %s/accelerer/accélérer/e
  silent! %s/interet/intérêt/e
  silent! %s/entete/entête/e

  execute 'normal '.linenr.'gg'
endfunction
" }}}
" Auto generate index.html when in a remark directory
let b:generateScript = expand('%:h').'/generate'
if filereadable(b:generateScript)
  augroup markdown_generate_remark
    au!
    au BufWritePost <buffer> silent! execute '!'.b:generateScript
  augroup END
endif
"
" Line endings {{{
setlocal fileformat=dos
au BufNewFile,BufRead,BufWritePre <buffer> silent call ConvertLineEndingsToDos()
" }}}
