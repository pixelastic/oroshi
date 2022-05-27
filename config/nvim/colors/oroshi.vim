" Name:         Oroshi
" Maintainer:   Tim Carry <tim@pixelastic.com>
" "C'est parce qu'il y a 6 matières, c'est ca ?"

" Initialization {{{
" Needed for nvim to color the cursor
set termguicolors
set background=dark
" Coloring current line
set cursorline
hi clear
if exists('syntax_on')
   syntax reset
endif
let g:colors_name = 'oroshi'
" }}}
" Defining the palette {{{
let s:color = {}
let s:color.black='#000000'
let s:color.white='#FFFFFF'
let s:color.terminal='#0c0f15'
" Gray {{{
let s:color.gray0='#808080'
let s:color.gray1='#f7fafc'
let s:color.gray2='#edf2f7'
let s:color.gray3='#e2e8f0'
let s:color.gray4='#cbd5e0'
let s:color.gray5='#a0aec0'
let s:color.gray6='#718096'
let s:color.gray7='#4a5568'
let s:color.gray8='#2d3748'
let s:color.gray9='#1a202c'
" }}}
" Red {{{
let s:color.red0='#ff0000'
let s:color.red1='#fff5f5'
let s:color.red2='#fed7d7'
let s:color.red3='#feb2b2'
let s:color.red4='#fc8181'
let s:color.red5='#f56565'
let s:color.red6='#e53e3e'
let s:color.red7='#c53030'
let s:color.red8='#9b2c2c'
let s:color.red9='#742a2a'
" }}}
" Green {{{
let s:color.green0='#00ff00'
let s:color.green1='#f0fff4'
let s:color.green2='#c6f6d5'
let s:color.green3='#9ae6b4'
let s:color.green4='#68d391'
let s:color.green5='#48bb78'
let s:color.green6='#38a169'
let s:color.green7='#2f855a'
let s:color.green8='#276749'
let s:color.green9='#22543d'
" }}}
" Yellow {{{
let s:color.yellow0='#ffff00'
let s:color.yellow1='#fffff0'
let s:color.yellow2='#fefcbf'
let s:color.yellow3='#faf089'
let s:color.yellow4='#f6e05e'
let s:color.yellow5='#ecc94b'
let s:color.yellow6='#d69e2e'
let s:color.yellow7='#b7791f'
let s:color.yellow8='#975a16'
let s:color.yellow9='#744210'
" }}}
" Blue {{{
let s:color.blue0='#0000ff'
let s:color.blue1='#ebf8ff'
let s:color.blue2='#bee3f8'
let s:color.blue3='#90cdf4'
let s:color.blue4='#63b3ed'
let s:color.blue5='#4299e1'
let s:color.blue6='#3182ce'
let s:color.blue7='#2b6cb0'
let s:color.blue8='#2c5282'
let s:color.blue9='#2a4365'
" }}}
" Purple {{{
let s:color.purple0='#ff00ff'
let s:color.purple1='#faf5ff'
let s:color.purple2='#e9d8fd'
let s:color.purple3='#d6bcfa'
let s:color.purple4='#b794f4'
let s:color.purple5='#9f7aea'
let s:color.purple6='#805ad5'
let s:color.purple7='#6b46c1'
let s:color.purple8='#553c9a'
let s:color.purple9='#44337a'
" }}}
" Teal {{{
let s:color.teal0='#00ffff'
let s:color.teal1='#e6fffa'
let s:color.teal2='#b2f5ea'
let s:color.teal3='#81e6d9'
let s:color.teal4='#4fd1c5'
let s:color.teal5='#38b2ac'
let s:color.teal6='#319795'
let s:color.teal7='#2c7a7b'
let s:color.teal8='#285e61'
let s:color.teal9='#234e52'
" }}}
" Orange {{{
let s:color.orange0='#ff8700'
let s:color.orange1='#fffaf0'
let s:color.orange2='#feebc8'
let s:color.orange3='#fbd38d'
let s:color.orange4='#ffaf00'
let s:color.orange5='#ed8936'
let s:color.orange6='#dd6b20'
let s:color.orange7='#c05621'
let s:color.orange8='#9c4221'
let s:color.orange9='#7b341e'
" }}}
" Indigo {{{
let s:color.indigo0='#5f00ff'
let s:color.indigo1='#ebf4ff'
let s:color.indigo2='#c3dafe'
let s:color.indigo3='#a3bffa'
let s:color.indigo4='#7f9cf5'
let s:color.indigo5='#667eea'
let s:color.indigo6='#5a67d8'
let s:color.indigo7='#4c51bf'
let s:color.indigo8='#434190'
let s:color.indigo9='#3c366b'
" }}}
" Pink {{{
let s:color.pink0='#d787ff'
let s:color.pink1='#fff5f7'
let s:color.pink2='#fed7e2'
let s:color.pink3='#fbb6ce'
let s:color.pink4='#f687b3'
let s:color.pink5='#ed64a6'
let s:color.pink6='#d53f8c'
let s:color.pink7='#b83280'
let s:color.pink8='#97266d'
let s:color.pink9='#702459'
" }}}

" Make {color} equal to {color}6
let s:color_names = keys(s:color)
for s:color_name in keys(s:color)
   " Skip non -6 colors
   if s:color_name !~? '6$'
      continue
   endif
   " Save base color as the -6
   let s:base_color_name = substitute(s:color_name, '6', '', '')
   let s:color[s:base_color_name] = s:color[s:color_name]
endfor
" }}}
" Highlighting function {{{
" args : group, foreground, background, decoration
function! s:Highlight(group,...)
  let name = get(a:, 'group')
  let foreground = get(a:, '1', '')
  let background = get(a:, '2', '')
  let decoration = get(a:, '3', '')

  " We clear all previous highlight, to start from a clean slate
  execute 'hi clear '.name

  " Everything is empty, we stop now
  if foreground == '' && background == '' && decoration == ''
    return
  endif

  " We build the highlight string
  let result = 'hi! '.name
  if foreground != ''
    let result .= ' guifg='.get(s:color, foreground)
  endif
  if background != ''
    let result .= ' guibg='.get(s:color, background)
  endif
  if decoration != ''
    let result .= ' gui='.decoration
  endif

  execute result
endfunction
" }}}
" Text {{{
call s:Highlight('Boolean', 'orange5')
call s:Highlight('Comment', 'gray')
call s:Highlight('Constant', 'yellow', '', 'bold')
call s:Highlight('Error', 'red', 'black', 'bold')
call s:Highlight('Function', 'yellow')
call s:Highlight('Identifier', 'indigo4', '', 'none')
call s:Highlight('Noise', 'teal7')
call s:Highlight('NonText', 'gray8')
call s:Highlight('Normal', 'gray4')
call s:Highlight('Number', 'blue5', '', 'bold')
call s:Highlight('Operator', 'teal7')
call s:Highlight('PreProc', 'yellow')
call s:Highlight('SpecialComment', 'yellow')
call s:Highlight('SpecialKey', 'yellow8')
call s:Highlight('Special', 'yellow')
call s:Highlight('Statement', 'pink')
call s:Highlight('StorageClass', 'red5')
call s:Highlight('String', 'blue5')
call s:Highlight('Title', 'yellow')
call s:Highlight('Todo', 'yellow', 'terminal', 'bold')
call s:Highlight('Type', 'red5')
call s:Highlight('ExtraWhitespace', '', 'gray9')
" The matcher needs to be defined after the colorscheme
match ExtraWhitespace /\s\+$/
" }}}
" UI {{{
" Borders {{{
call s:Highlight('ColorColumn', 'yellow', 'gray9')
call s:Highlight('LineNr', 'gray')
call s:Highlight('SignColumn', 'none', 'terminal')
call s:Highlight('VertSplit', 'gray9', 'gray9', 'bold')
" }}}
" Tabs {{{
call s:Highlight('TabLineFill', 'gray8', 'gray9', 'none')
call s:Highlight('TabLineSel', 'yellow', 'gray8', 'bold')
call s:Highlight('TabLine', 'gray4', 'gray9', 'none')
" }}}
" Cursor {{{
call s:Highlight('CursorLineNr', 'yellow', '', 'bold')
call s:Highlight('CursorLine', '', 'gray9', 'none')

" Normal mode
call s:Highlight('CursorNormal', '', 'red', 'none')
let s:guicursor = "n:block-CursorNormal"

" Waiting for an operator
call s:Highlight('CursorOperatorPending', '', 'red5', 'none')
let s:guicursor .= ",o:block-CursorOperatorPending"

" Insert mode
call s:Highlight('CursorInsert', '', 'yellow', 'none')
let s:guicursor .= ",i:block-CursorInsert"

" Visual mode
call s:Highlight('CursorVisual', '', 'blue', 'none')
let s:guicursor .= ",v:block-CursorVisual"

" Command mode
call s:Highlight('CursorCommand', '', 'teal', 'none')
let s:guicursor .= ",c:block-CursorCommand"
" When editing the current command
call s:Highlight('CursorCommandInsert', '', 'teal', 'none')
let s:guicursor .= ",ci:block-CursorCommandInsert"

" Not sure what those do, so let's color them pink and see when that happens
call s:Highlight('CursorReplace', '', 'pink', 'none')
let s:guicursor .= ",r:block-CursorReplace"
call s:Highlight('CursorCommandReplace', '', 'pink', 'none')
let s:guicursor .= ",cr:block-CursorCommandReplace"
call s:Highlight('CursorInsertShowmatch', '', 'pink', 'none')
let s:guicursor .= ",sm:block-CursorInsertShowmatch"

execute 'set guicursor='.s:guicursor
" }}}
" Folds {{{
call s:Highlight('Folded', 'gray5', 'gray9')
" }}}
" Visual selection {{{
call s:Highlight('Visual', 'white', 'blue', 'bold')
" }}}
" Search {{{
call s:Highlight('IncSearch', 'black', 'green', 'none')
call s:Highlight('Search', 'black', 'green', 'bold')
" }}}
" Syntastic gutter {{{
call s:Highlight('SyntasticErrorSign', 'red')
call s:Highlight('SyntasticStyleErrorSign', 'red')
call s:Highlight('SyntasticStyleWarningSign', 'yellow')
call s:Highlight('SyntasticWarningSign', 'yellow')
" }}}
" Coc Gutter {{{
call s:Highlight('CocErrorSign', 'red')
call s:Highlight('CocWarningSign', 'yellow')
call s:Highlight('CocInfoSign', 'blue')
" }}}
" GitGutter {{{
call s:Highlight('GitGutterAdd', 'green')
call s:Highlight('GitGutterChange', 'purple')
" }}}
" Status line {{{
call s:Highlight('StatusLineFileEncodingError', 'red', 'gray8')
call s:Highlight('StatusLineFileFormatError', 'red', 'gray8')
call s:Highlight('StatusLineGitClean', 'green', 'gray8')
call s:Highlight('StatusLineGitDirty', 'red', 'gray8', 'bold')
call s:Highlight('StatusLineGitStaged', 'purple4', 'gray8')
call s:Highlight('StatusLineModeCtrlPSeparator', 'red5', 'gray8')
call s:Highlight('StatusLineModeCtrlP', 'black', 'red5', 'bold')
call s:Highlight('StatusLineModeInsertSeparator', 'yellow', 'gray8')
call s:Highlight('StatusLineModeInsert', 'black', 'yellow', 'bold')
call s:Highlight('StatusLineModeNormalSeparator', 'black', 'gray8')
call s:Highlight('StatusLineModeNormal', 'white', 'black')
call s:Highlight('StatusLineModeSearchSeparator', 'green', 'gray8')
call s:Highlight('StatusLineModeSearch', 'black', 'green', 'bold')
call s:Highlight('StatusLineModeCommandSeparator', 'teal', 'gray8')
call s:Highlight('StatusLineModeCommand', 'black', 'teal', 'bold')
call s:Highlight('StatusLineModeUnknownSeparator', 'red', 'white')
call s:Highlight('StatusLineModeUnknown', 'white', 'red')
call s:Highlight('StatusLineModeVisualSeparator', 'blue', 'gray8')
call s:Highlight('StatusLineModeVisual', 'white', 'blue', 'bold')
call s:Highlight('StatusLineNC', '', 'gray8', 'none')
call s:Highlight('StatusLinePathModified', 'purple4', 'gray8')
call s:Highlight('StatusLinePathReadonly', 'red', 'gray8')
call s:Highlight('StatusLinePath', 'green', 'gray8', 'bold')
call s:Highlight('StatusLineRight', 'gray4', 'gray8', 'none')
call s:Highlight('StatusLineError', 'red', 'gray8')
call s:Highlight('StatusLineWarning', 'yellow', 'gray8')
call s:Highlight('StatusLine', 'gray4', 'gray8', 'none')
" }}}
" FZF {{{
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }
" }}}
" COC {{{
" Autocompletion menu
call s:Highlight('Pmenu', 'white', 'teal9')
call s:Highlight('PmenuSel', 'yellow', 'teal8', 'bold')
call s:Highlight('PmenuSbar', 'gray9', 'gray9')
call s:Highlight('PmenuThumb', 'teal8', 'teal8')
" Error checking
" Note: We don't highlight Coc errors as they tend to put everything under the
" same color and make it hard to visually parse. We rely on the gutter symbol
" instead.
" call s:Highlight('CocWarningHighlight', 'yellow', '', 'bold,underline')
" call s:Highlight('CocInfoHighlight', '', '', 'none')
call s:Highlight('CocFloating', 'gray5', 'gray9')
call s:Highlight('CocWarningFloat', 'yellow', 'gray9', 'bold')
call s:Highlight('CocErrorFloat', 'red', 'gray9', 'bold')
call s:Highlight('CocErrorHighlight', '', '', 'bold')

" call s:Highlight('CocBold', 'pink', 'white')
" call s:Highlight('CocCodeLens', 'pink', 'white')
" call s:Highlight('CocCursorRange', 'pink', 'white')
" call s:Highlight('CocErrorHighlight', 'pink', 'white')
" call s:Highlight('CocHighlightRead', 'pink', 'white')
" call s:Highlight('CocHighlightText', 'pink', 'white')
" call s:Highlight('CocHighlightWrite', 'pink', 'white')
" call s:Highlight('CocHintFloat', 'pink', 'white')
" call s:Highlight('CocHintHighlight', 'pink', 'white')
" call s:Highlight('CocHintSign', 'pink', 'white')
" call s:Highlight('CocHoverRange', 'pink', 'white')
" call s:Highlight('CocInfoFloat', 'pink', 'white')
" call s:Highlight('CocInfoHighlight', 'pink', 'white')
" call s:Highlight('CocInfoSign', 'pink', 'white')
" call s:Highlight('CocItalic', 'pink', 'white')
" call s:Highlight('CocListMode', 'pink', 'white')
" call s:Highlight('CocListPath', 'pink', 'white')
" call s:Highlight('CocMarkdownCode', 'pink', 'white')
" call s:Highlight('CocMarkdownHeader', 'pink', 'white')
" call s:Highlight('CocMarkdownLink', 'pink', 'white')
" call s:Highlight('CocMenuSel', 'pink', 'white')
" call s:Highlight('CocSelectedText', 'pink', 'white')
" call s:Highlight('CocUnderline', 'pink', 'white')
" call s:Highlight('CocWarningHighlight', 'pink', 'white')
" }}}
" Matching parenthesis {{{
call s:Highlight('MatchParen', 'white', 'teal9')
" }}}
" Messages {{{
call s:Highlight('ErrorMsg', 'red', 'none', 'bold')
call s:Highlight('WarningMsg', 'yellow8')
" }}}
" Spell Checking / Errors {{{
call s:Highlight('SpellBad', 'red', 'terminal', 'bold,underline')
call s:Highlight('SpellCap', 'red', 'terminal', 'bold,underline')
" }}}

" AutoIt {{{
call s:Highlight('autoitString', 'blue5')
call s:Highlight('autoitQuote', 'blue5')
call s:Highlight('autoitNumber', 'blue5', '', 'bold')
call s:Highlight('autoitParen', 'teal7')
call s:Highlight('autoitKeyword', 'green7')
call s:Highlight('autoitVariable', 'indigo4')
call s:Highlight('autoitVarSelector', 'indigo4', '', 'bold')
call s:Highlight('autoitFunction', 'yellow')
call s:Highlight('autoitBuiltin', 'yellow', '', 'bold')
" }}}
" CSS {{{
call s:Highlight('scssImport', 'yellow', '', 'bold')
call s:Highlight('cssBraces', 'teal7')
call s:Highlight('scssSelectorChar', 'teal7')
call s:Highlight('scssSemicolon', 'teal7')
" }}}
" Git {{{
call s:Highlight('diffAdded', 'green5')
call s:Highlight('diffFile', 'yellow6')
call s:Highlight('diffIndexLine', 'yellow7')
call s:Highlight('diffOldFile', 'yellow8')
call s:Highlight('diffNewFile', 'yellow8')
call s:Highlight('diffLine', 'terminal')
call s:Highlight('diffRemoved', 'red7')
call s:Highlight('diffSubname', 'gray6')
call s:Highlight('gitDiff', 'gray')
call s:Highlight('gitcommitBlank', 'red')
call s:Highlight('gitcommitBranch', 'orange')
call s:Highlight('gitcommitDiff', 'gray')
call s:Highlight('gitcommitHeader', 'gray')
call s:Highlight('gitcommitOverflow', 'white', 'red')
call s:Highlight('gitcommitSelectedFile', 'green')
call s:Highlight('gitcommitSummary', 'white')
call s:Highlight('gitcommitUntrackedFile', 'gray')
call s:Highlight('gitconfigAssignment', 'blue')
call s:Highlight('gitconfigVariable', 'indigo')
" }}}
" HTML {{{
call s:Highlight('htmlTagName', 'green7')
call s:Highlight('htmlTag', 'teal7')
" }}}
" JavaScript / TypeScript {{{
call s:Highlight('jsArrowFunction', 'teal7')
call s:Highlight('jsAsyncKeyword', 'green7')
call s:Highlight('jsBooleanFalse', 'red5', '', 'bold')
call s:Highlight('jsBooleanTrue', 'green', '', 'bold')
call s:Highlight('jsDestructuringBlock', 'indigo5')
call s:Highlight('jsForAwait', 'green7')
call s:Highlight('jsFuncArgs', 'indigo5')
call s:Highlight('jsFunction', 'red5')
call s:Highlight('jsNoise', 'teal7')
call s:Highlight('jsNull', 'pink5', '', 'bold')
call s:Highlight('jsOperatorKeyword', 'green7', '', 'bold')
call s:Highlight('jsParens', 'teal7')
call s:Highlight('jsRegexpBoundary', 'orange')
call s:Highlight('jsRegexpGroup', 'green')
call s:Highlight('jsRegexpOr', 'orange')
call s:Highlight('jsRegexpQuantifier', 'orange')
call s:Highlight('jsRegexpString', 'blue4')
call s:Highlight('jsReturn', 'green', '', 'bold')
call s:Highlight('jsStorageClass', 'green7')
call s:Highlight('jsTemplateBraces', 'indigo4')
call s:Highlight('jsTemplateExpression', 'indigo4')
call s:Highlight('jsTemplateString', 'blue6')
call s:Highlight('jsThis', 'indigo4')
call s:Highlight('jsUndefined', 'orange6', '', 'bold')
call s:Highlight('jsVariableDef', 'indigo4')
call s:Highlight('typescriptAccessibilityModifier', 'green7')
call s:Highlight('typescriptAssign', 'teal7')
call s:Highlight('typescriptBOMWindowProp', 'yellow', '', 'bold')
call s:Highlight('typescriptBraces', 'teal7')
call s:Highlight('typescriptClassKeyword', 'green7')
call s:Highlight('typescriptClassName', 'pink8', '', 'bold')
call s:Highlight('typescriptDOMDocProp', 'yellow')
call s:Highlight('typescriptDotNotation', 'teal7')
call s:Highlight('typescriptEndColons', 'teal7')
call s:Highlight('typescriptFuncCallArg', 'indigo5')
call s:Highlight('typescriptFuncKeyword', 'red5')
call s:Highlight('typescriptInterfaceKeyword', 'green7')
call s:Highlight('typescriptInterfaceName', 'pink8', '', 'bold')
call s:Highlight('typescriptMember', 'indigo5')
call s:Highlight('typescriptOperator', 'green7', '', 'bold')
call s:Highlight('typescriptObjectLabel', 'indigo5')
call s:Highlight('typescriptParens', 'teal7')
call s:Highlight('typescriptPredefinedType', 'pink8')
call s:Highlight('typescriptStatementKeyword', 'green', '', 'bold')
call s:Highlight('typescriptTypeAnnotation', 'teal7')
call s:Highlight('typescriptTypeReference', 'pink6')
call s:Highlight('typescriptTypeBrackets', 'teal7')
call s:Highlight('typescriptVariableDeclaration', 'indigo4')
call s:Highlight('typescriptVariable', 'green7')
" This doesn't seem to apply v
call s:Highlight('typescriptIdentifierName', 'white', 'red', 'bold')
call s:Highlight('typescriptProp', 'yellow', 'red', 'bold')
" }}}
" JSONC {{{
call s:Highlight('jsoncKeywordMatch', 'blue5')
augroup oroshi_jsonc
  autocmd!
  " The "Normal" highlight group is used for commas
  autocmd FileType jsonc call s:Highlight('Normal', 'teal7')
augroup END
" }}}
" Markdown {{{
call s:Highlight('markdownCodeDelimiter', 'blue5')
call s:Highlight('markdownCode', 'blue5')
call s:Highlight('markdownH1', 'green4', '', 'bold')
call s:Highlight('markdownH2', 'green5', '', 'bold')
call s:Highlight('markdownH3', 'green6', '', 'bold')
call s:Highlight('markdownH4', 'green7', '', 'bold')
call s:Highlight('markdownH5', 'green8', '', 'bold')
call s:Highlight('markdownH6', 'green9', '', 'bold')
call s:Highlight('markdownLinkDelimiter', 'yellow8')
call s:Highlight('markdownLinkTextDelimiter', 'indigo8')
call s:Highlight('markdownLinkText', 'indigo5', '', 'underline')
call s:Highlight('markdownRule', 'teal')
call s:Highlight('markdownUrl', 'yellow')
" }}}
" Pug {{{
call s:Highlight('pugAngular2', 'blue4', '', 'italic,bold')
call s:Highlight('pugAttributes', 'red5')
call s:Highlight('pugClassChar', 'teal7')
call s:Highlight('pugJavascriptChar', 'teal7')
call s:Highlight('pugJavascriptOutputChar', 'teal7')
call s:Highlight('pugScriptLoopKeywords', 'yellow')
call s:Highlight('pugTag', 'yellow')
" }}}
" Ruby {{{
call s:Highlight('rubyDefine', 'green')
call s:Highlight('rubyStringDelimiter', 'blue5')
call s:Highlight('rubySymbol', 'orange5')
" }}}
" Shell {{{
call s:Highlight('shDerefSimple', 'indigo4')
call s:Highlight('shDerefVar', 'indigo4')
call s:Highlight('shOption', 'indigo4')
call s:Highlight('shQuote', 'blue5')
call s:Highlight('shSemicolon', 'teal7')
call s:Highlight('shSetOption', 'indigo4')
call s:Highlight('shSet', 'green7')
call s:Highlight('shStatement', 'yellow7')
call s:Highlight('shVarAssign', 'teal7')
" }}}
" Tmux {{{
call s:Highlight('tmuxBoolean', 'orange', '', 'bold')
call s:Highlight('tmuxCommands', 'green')
" }}}
" Vim {{{
call s:Highlight('vimCommand', 'green7')
call s:Highlight('vimFunction', 'yellow6')
call s:Highlight('vimFunc', 'yellow6')
call s:Highlight('vimOperParen', 'teal7')
call s:Highlight('vimOption', 'indigo4')
call s:Highlight('vimParenSep', 'teal7')
call s:Highlight('vimUserFunc', 'yellow6')
" }}}
" Yaml {{{
call s:Highlight('yamlAlias', 'yellow6')
call s:Highlight('yamlBlockCollectionItemStart', 'teal7')
call s:Highlight('yamlFlowString', 'blue5')
call s:Highlight('yamlKeyValueDelimiter', 'teal7')
call s:Highlight('yamlPlainScalar', 'blue5')
" }}}
" Zsh {{{
call s:Highlight('ZinitIceModifiers', 'indigo4')
call s:Highlight('zshBrackets', 'teal7')
call s:Highlight('zshCommands', 'green7')
call s:Highlight('zshDelim', 'teal7')
call s:Highlight('zshKeyword', 'green7')
call s:Highlight('zshOptStart', 'green7', '', 'bold')
call s:Highlight('zshOption', 'orange', '', 'bold')
call s:Highlight('zshParentheses', 'teal7')
call s:Highlight('zshStringDelimiter', 'blue5')
call s:Highlight('zshSwitches', 'indigo4')
call s:Highlight('zshVariableDef', 'indigo4')
" }}}


" " Ansible {{{
" call s:Link('jinjaVariable', 'oroshi_TextSpecial')
" call s:Link('jinjaOperator', 'oroshi_TextSpecial')
" call s:Link('jinjaAttribute', 'oroshi_TextSpecial')
" call s:Link('jinjaVarDelim', 'oroshi_TextSpecial')
" call s:Link('ansibleRepeat', 'oroshi_CodeChute')
" call s:Link('ansibleConditional', 'oroshi_CodeStatement')
" " }}}
" " Robots {{{
" call s:Link('robotsDelimiter', 'oroshi_Text')
" call s:Link('robotsAgent', 'oroshi_CodeStatement')
" call s:Link('robotsDisallow', 'oroshi_CodeType')
" call s:Link('robotsLine', 'oroshi_CodeString')
" call s:Link('robotsStar', 'oroshi_CodeSymbol')
" " }}}
" " Vim {{{
" call s:Highlight('VimLineComment', 'gray')
" call s:Highlight('VimCommentTitle', 'yellow')
" call s:Highlight('VimTodo', 'yellow')
" call s:Link('vimParenSep', 'oroshi_Text')
" call s:Link('vimIsCommand', 'oroshi_CodeVariable')
" " Option keys
" call s:Link('vimOption', 'oroshi_CodeSymbol')
" call s:Link('vimFTOption', 'oroshi_CodeSymbol')
" call s:Link('vimHiClear', 'oroshi_CodeSymbol')
" call s:Link('vimSynType', 'oroshi_CodeSymbol')
" call s:Link('vimAutoEvent', 'oroshi_CodeSymbol')
" call s:Link('vimNormCmds', 'oroshi_CodeSymbol')
" call s:Link('vimMapLhs', 'oroshi_CodeSymbol')
" " , 'orange', 'none')
" " Option values
" call s:Link('vimSet', 'oroshi_CodeString')
" call s:Link('vimSetEqual', 'oroshi_CodeString')
" call s:Link('vimMapRhs', 'oroshi_CodeString')
" " Functions
" call s:Link('vimFunction', 'oroshi_CodeFunction')
" call s:Link('vimUserFunc', 'oroshi_CodeFunction')
" call s:Link('vimFuncKey', 'oroshi_CodeType')
" " Normal commands
" call s:Link('vimNormCmds', 'oroshi_Text')
" call s:Link('vimUserAttrb', 'oroshi_Text')
" " Special keys
" call s:Highlight('vimMapMod', 'yellow')
" call s:Highlight('vimMapModKey', 'yellow')
" call s:Link('vimAutoCmdSfxList', 'oroshi_TextSpecial')
" call s:Link('vimCtrlCharMod', 'oroshi_TextSpecial')
" " Regexps
" call s:Link('vimSubstFlags', 'oroshi_CodeRegexpFlags')
" call s:Link('vimAddress', 'oroshi_CodeRegexpFlags')
" call s:Link('vimSubst1', 'oroshi_CodeRegexpFlags')
" call s:Link('vimSubstPat', 'oroshi_CodeRegexp')
" call s:Link('vimSubstRep4', 'oroshi_CodeRegexp')
" call s:Link('vimSubstDelim', 'oroshi_CodeRegexpDelimiter')
" " Vim Help
" call s:Link('helpHeader', 'oroshi_TextHeadingOne')
" call s:Link('helpVim', 'oroshi_TextHeadingOne')
" call s:Link('helpNotVi', 'oroshi_Notice')
" call s:Link('helpSectionDelim', 'oroshi_TextDelimiter')
" call s:Link('helpSpecial', 'oroshi_CodeString')
" call s:Link('helpHyperTextEntry', 'oroshi_TextLink')
" call s:Link('helpExample', 'oroshi_CodeString')
" call s:Link('helpOption', 'oroshi_CodeSymbol')
" " }}}
" " YAML {{{
" call s:Link('yamlBlockMappingKey', 'oroshi_CodeType')
" call s:Link('yamlBlockCollectionItemStart', 'oroshi_Text')
" call s:Link('yamlDelimiter', 'oroshi_Text')
" call s:Link('yamlKeyValueDelimiter', 'oroshi_Text')
" call s:Link('yamlKey', 'oroshi_CodeType')
" call s:Link('yamlNull', 'yamlScalar')
" call s:Link('yamlPlainScalar', 'oroshi_CodeStatement')
" call s:Link('yamlAlias', 'oroshi_CodeInclude')
" call s:Highlight('yamlAnchor', 'yellow8', 'none', 'bold')
" call s:Highlight('yamlBlockMappingMerge', 'yellow8', 'none', 'bold')
" " }}}
" " XML {{{
" call s:Link('xmlAttribPunct', 'oroshi_CodeStatement')
" call s:Link('xmlNamespace', 'oroshi_CodeStatement')
" call s:Link('xmlTag', 'oroshi_CodeStatement')
" call s:Link('xmlTagName', 'oroshi_CodeStatement')
" call s:Link('xmlEndTag', 'oroshi_CodeStatement')
" " }}}
" " Diff {{{
" call s:Link('diffAdded', 'oroshi_DiffAdded')
" call s:Link('diffRemoved', 'oroshi_DiffRemoved')
" call s:Link('DiffFile', 'oroshi_CodeComment')
" call s:Link('DiffNewFile', 'oroshi_CodeComment')
" call s:Link('DiffLine', 'oroshi_DiffLine')
" call s:Link('diffSubname', 'oroshi_Normal')
" call s:Link('diffBDiffer', 'oroshi_CodeInclude')
" " }}}
