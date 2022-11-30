" MARKDOWN
" Saving {{{
" This will save the file on disk as often as possible. When writing markdown,
" I don't want to lose what I wrote because of a glitch.
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
"
let b:npmRoot = GetNpmRoot()

" Textlint
let b:textlintBin = StrTrim(system('yarn bin textlint 2>/dev/null'))
if b:textlintBin ==# ''
  let b:textlintBin = StrTrim(system('which textlint'))
endif

" Remark (as a linter and a fixer)
let b:remarkLintBin = StrTrim(system('which remark-lint'))
let b:remarkFixBin = StrTrim(system('which remark-fix'))

" Prettier
let b:prettierBin = StrTrim(system('yarn bin prettier 2>/dev/null'))
if b:prettierBin ==# ''
  let b:prettierBin = StrTrim(system('which prettier'))
endif

let b:syntastic_checkers = ['textlint', 'remark_lint']
let b:syntastic_markdown_textlint_exec = b:textlintBin
let b:syntastic_markdown_remark_lint_exec = b:remarkLintBin
" }}}
" Cleaning the file {{{
inoremap <silent> <buffer> <F4> <Esc>:call MarkdownBeautify()<CR>
nnoremap <silent> <buffer> <F4> :call MarkdownBeautify()<CR>
function! MarkdownBeautify() 
  let l:initialLine = line('.')

  " Remark: fix markdown formatting. This will mostly convert links to references
  execute '%!'.b:remarkFixBin.' "%:p"'

  " Textlint: fix fixable textlint issues. As this will change the file in place, we use
  " /tmp as a buffer
  let tmpFile = '/tmp/vim-textlint-markdown.md'
  let command = '%!> ' . tmpFile .
        \' && ' . b:textlintBin . ' --fix ' . tmpFile . ' --output-file /dev/null' .
        \' && cat ' . tmpFile
  execute command

  " Prettier: Make everything look the same
  write
  silent execute '%!' . b:prettierBin . ' --parser markdown "%:p"'

  " call RemoveTrailingSpaces()

  execute 'normal '.initialLine.'gg'
  SyntasticCheck()
endfunction
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
" Wrapping {{{
" Auto-wrap text
setlocal formatoptions+=t
" }}}
" Keybindings {{{
" Add current copy-paste buffer to link on word
nnoremap <buffer> ]] "zciw[<Esc>"zpi<Right>](<Esc>"*pi<Right>)<Esc>mzvipgq`z
vnoremap <buffer> ]] "zc[]()<Esc>hhh"zpll"*p
" }}}
" Spellchecking {{{
setlocal spelllang=en
" Change language and/or toggle
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
