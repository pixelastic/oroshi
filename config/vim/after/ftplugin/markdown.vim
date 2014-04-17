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
" Line endings {{{
" Use windows line endings so readme files can be easily edited on Notepad
setlocal fileformat=dos
au BufNewFile,BufRead,BufWritePre <buffer> silent call ConvertLineEndingsToDos()
" }}}
