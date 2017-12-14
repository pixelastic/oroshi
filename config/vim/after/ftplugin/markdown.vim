" MARKDOWN
" I write most of my markdown in english, and sometimes in french. I will
" disable English-only settings when I know I'm in a french directory
let thisFile = expand('%:p')
let isRoleplay = thisFile =~# 'roleplay'
let isBooks = thisFile =~# 'books'

" Saving {{{
augroup markdown_autosave
  au!
  autocmd CursorHold <Buffer> update
  autocmd CursorHoldI <Buffer> update
  autocmd TabEnter <Buffer> update
augroup END
" }}}
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
" Linters {{{
if or(isRoleplay, isBooks) ==# 0
  let b:syntastic_checkers = ['textlint']
endif
" }}}
" Folding {{{
function! MarkdownLevel()
  let currentLine = getline(v:lnum)
  let headerMarker = matchstr(currentLine, '^#\+')
  let headerLevel = len(headerMarker)

  if headerLevel > 0
    return '>'.headerLevel
  endif

  return '='
endfunction
setlocal foldexpr=MarkdownLevel()  
setlocal foldmethod=expr  
" }}}
" Running the file in the browser {{{
nnoremap <silent> <buffer> <F5> :call MarkdownPreview()<CR>
function! MarkdownPreview()
  silent execute ':!nohup markdown-preview % &>/dev/null &'
  redraw!
endfunction
" }}}
" Wrapping {{{
" Auto-wrap text
setlocal formatoptions+=t
" }}}
" Keybindings {{{
" Add current copy-paste buffer to link on word
nnoremap <buffer> ]] "zciw[<Esc>"zpi<Right>](<Esc>"*pi<Right>)<Esc>mzvipgq`z
vnoremap <buffer> ]] "zc[]()<Esc>hhh"zpll"*p
" }}}
" Cleaning the file {{{
inoremap <silent> <buffer> <F4> <Esc>:call MarkdownBeautify()<CR>
nnoremap <silent> <buffer> <F4> :call MarkdownBeautify()<CR>
function! MarkdownBeautify() 
  " We save the current line, to be able to jump to it later
  let linenr=line('.')

  " Remove bad chars after copy-paste
  silent! %s/’/'/e
  silent! %s/‘/'/e
  silent! %s/“/"/e
  silent! %s/”/"/e

  " Textlint
  let thisFile = shellescape(expand('%:p'))
  let tmpFile = '/tmp/vim-textlint-markdown.md'
  " textlint --fix changes the file in place. So we copy the content into a tmp
  " file, fix it, and then output the fixed file
  let command = '%!> ' . tmpFile .
        \' && textlint --fix ' . tmpFile . ' &>/dev/null' .
        \' && cat ' . tmpFile
  execute command

  " Remove trailing spaces
  call RemoveTrailingSpaces()

  " Convert links into references
  silent! %! formd -r

  " Get back to initial line
  execute 'normal '.linenr.'gg'
endfunction
" }}}
" Spellchecking {{{
setlocal spelllang=en
if isRoleplay ==# 1
  setlocal spelllang=fr
endif
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
nnoremap <buffer> ss viw<Esc>i<C-X>s<C-N><C-P>
" }}}
" Map drawing {{{
nnoremap <buffer> <Leader>wh r━
vnoremap <buffer> <Leader>wh r━
nnoremap <buffer> <Leader>wv r┃
vnoremap <buffer> <Leader>wv r┃
nnoremap <buffer> <Leader>wtl r┏
nnoremap <buffer> <Leader>wtr r┓
nnoremap <buffer> <Leader>wbr r┛
nnoremap <buffer> <Leader>wbl r┗
nnoremap <buffer> <Leader>wxx r╋
nnoremap <buffer> <Leader>wxt r┻
nnoremap <buffer> <Leader>wxr r┣
nnoremap <buffer> <Leader>wxb r┳
nnoremap <buffer> <Leader>wxl r┫
" }}}
