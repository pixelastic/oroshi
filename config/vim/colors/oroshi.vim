" Name:         Oroshi
" Maintainer:   Tim Carry <tim@pixelastic.com>
" "C'est parce qu'il y a 6 matières, c'est ca ?"

" Initialization {{{
set t_Co=256
set background=dark
hi clear
if exists('syntax_on')
   syntax reset
endif
let g:colors_name = 'oroshi'
" }}}
" Generating the palette {{{
" The order of the colors is important and must match what is defined in
" kitty.conf
let s:color = {}
let s:color.black=0
let s:color.white=15
let s:color.terminal=16
let orderedColors = [
      \'gray', 
      \'red', 
      \'green', 
      \'yellow', 
      \'blue', 
      \'purple', 
      \'teal', 
      \'orange', 
      \'indigo', 
      \'pink'
      \]

let colorCount=len(orderedColors)
let colorGroupIndex = 0
while colorGroupIndex < colorCount
  let colorGroupName = get(orderedColors, colorGroupIndex)

  let colorIndex = 1
  while colorIndex < 10
    let colorName = colorGroupName . colorIndex
    let colorValue = 20 + (colorGroupIndex * 10) + colorIndex
    let s:color[colorName]=colorValue
    let colorIndex += 1
  endwhile
  " Easy access to the color
  let s:color[colorGroupName]=s:color[colorGroupName.'6']

  let colorGroupIndex += 1
endwhile
" }}}
" Highlighting function {{{
" args : group, foreground, background, cterm
function! s:Highlight(group,...)
  let name = get(a:, 'group')
  let foreground = get(a:, '1', '')
  let background = get(a:, '2', '')
  let decoration = get(a:, '3', '')

  " Everything is empty, we clear the highlight
  if foreground == '' && background == '' && decoration == ''
    execute 'hi clear '.name
    return
  endif

  " We build the highlight string
  let result = 'hi! '.name
  if foreground != ''
    let result .= ' ctermfg='.get(s:color, foreground)
  endif
  if background != ''
    let result .= ' ctermbg='.get(s:color, background)
  endif
  if decoration != ''
    let result .= ' cterm='.decoration
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
if &term =~ "xterm"
  " Cursor in insert mode
  let &t_SI = "\<Esc>]12;#AF8700\x7"
  " Cursor in normal mode
  let &t_EI = "\<Esc>]12;#D70000\x7"
endif
" }}}
" Folds {{{
call s:Highlight('Folded', 'gray5', 'gray9')
" }}}
" Visual selection {{{
call s:Highlight('Visual', 'white', 'blue', 'bold')
" }}}
" Search {{{
call s:Highlight('IncSearch', 'black', 'yellow', 'none')
call s:Highlight('Search', 'black', 'yellow', 'bold')
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
call s:Highlight('StatusLineModeNormalSeparator', 'none', 'gray8')
call s:Highlight('StatusLineModeNormal', 'white', 'black')
call s:Highlight('StatusLineModeSearchSeparator', 'yellow', 'gray8')
call s:Highlight('StatusLineModeSearch', 'black', 'yellow', 'bold')
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
call s:Highlight('CocErrorHighlight', 'red', '', 'bold,underline')
call s:Highlight('CocWarningHighlight', 'yellow', '', 'bold,underline')
call s:Highlight('CocInfoHighlight', '', '', 'none')
call s:Highlight('CocFloating', 'gray5', 'gray9')
call s:Highlight('CocWarningFloat', 'yellow', 'gray9', 'bold')
call s:Highlight('CocErrorFloat', 'red', 'gray9', 'bold')
" }}}
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
" Spell Checking / Errors
call s:Highlight('SpellBad', 'red', 'terminal', 'bold,underline')
call s:Highlight('SpellCap', 'red', 'terminal', 'bold,underline')
" }}}

" CSS {{{
call s:Highlight('scssImport', 'yellow', '', 'bold')
call s:Highlight('cssBraces', 'teal7')
call s:Highlight('scssSelectorChar', 'teal7')
call s:Highlight('scssSemicolon', 'teal7')
" }}}
" Git {{{
call s:Highlight('diffAdded', 'green5')
call s:Highlight('diffFile', 'teal6')
call s:Highlight('diffIndexLine', 'teal6')
call s:Highlight('diffLine', 'teal6')
call s:Highlight('diffRemoved', 'red7')
call s:Highlight('diffSubname', 'gray6')
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
call s:Highlight('typescriptFuncCallArg', 'teal7')
call s:Highlight('typescriptFuncKeyword', 'red5')
call s:Highlight('typescriptInterfaceKeyword', 'green7')
call s:Highlight('typescriptInterfaceName', 'pink8', '', 'bold')
call s:Highlight('typescriptMember', 'indigo5')
call s:Highlight('typescriptOperator', 'green7', '', 'bold')
call s:Highlight('typescriptParens', 'teal7')
call s:Highlight('typescriptPredefinedType', 'pink8')
call s:Highlight('typescriptStatementKeyword', 'green', '', 'bold')
call s:Highlight('typescriptTypeAnnotation', 'teal7')
call s:Highlight('typescriptTypeReference', 'pink8')
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
call s:Highlight('pugScriptLoopKeywords', 'pink4')
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
" " CSS {{{
" call s:Link('sassClass', 'oroshi_CodeFunction')
" call s:Link('sassClassChar', 'oroshi_CodeFunction')
" call s:Link('sassAmpersand', 'oroshi_CodeSelf')
" call s:Link('scssSelectorName', 'oroshi_CodeVariable')
" call s:Link('scssProperty', 'oroshi_CodeSymbol')
" call s:Link('scssParameterList', 'oroshi_CodeSymbol')
" call s:Link('cssAttrComma', 'oroshi_Text')
" call s:Link('cssAttr', 'oroshi_CodeSymbol')
" call s:Link('cssBraces', 'oroshi_Text')
" call s:Link('cssColor', 'oroshi_CodeNumber')
" call s:Link('cssClassName', 'oroshi_CodeVariable')
" call s:Link('cssClassNameDot', 'oroshi_TextSpecial')
" call s:Link('cssFunction', 'oroshi_CodeSymbol')
" call s:Link('cssImportant', 'oroshi_Error')
" call s:Link('cssIncludeKeyword', 'oroshi_CodeInclude')
" call s:Link('cssMedia', 'oroshi_CodeInclude')
" call s:Link('cssProp', 'oroshi_CodeType')
" call s:Link('cssPseudoClassId', 'oroshi_CodeVariable')
" call s:Link('cssUnitDecorators', 'oroshi_CodeNumber')
" call s:Link('cssValueLength', 'oroshi_CodeNumber')
" call s:Link('cssVendorPrefixProp', 'oroshi_CodeType')
" " }}}
" " HTML {{{
" call s:Link('htmlTag', 'oroshi_CodeStatement')
" call s:Link('htmlTagName', 'oroshi_CodeStatement')
" call s:Link('htmlEndTag', 'oroshi_CodeStatement')
" call s:Link('htmlSpecialTagName', 'oroshi_CodeStatement')
" call s:Link('htmlTagN', 'oroshi_CodeStatement')
" call s:Link('htmlH1', 'oroshi_Text')
" call s:Link('htmlItalic', 'oroshi_Text')
" call s:Link('htmlLink', 'oroshi_Text')
" call s:Link('htmlTitle', 'oroshi_Text')
" " }}}
" " Markdown {{{
" call s:Link('MarkdownRule', 'oroshi_TextDelimiter')
" call s:Link('MarkdownBold', 'oroshi_TextBold')
" call s:Link('MarkdownItalic', 'oroshi_TextItalic')
" call s:Link('MarkdownListMarker', 'oroshi_Text')
" " Links
" call s:Link('markdownLinkDelimiter', 'oroshi_TextLink')
" call s:Link('markdownIdDeclaration', 'oroshi_TextLink')
" call s:Link('markdownLinkTextDelimiter', 'oroshi_TextLink')
" call s:Link('markdownLinkText', 'oroshi_TextLink')
" call s:Link('markdownUrl', 'oroshi_TextUrl')
" call s:Link('markdownId', 'oroshi_TextUrl')
" call s:Link('markdownIdDelimiter', 'oroshi_TextUrl')
" " Headings
" call s:Link('MarkdownH1', 'oroshi_TextHeadingOne')
" call s:Link('MarkdownH2', 'oroshi_TextHeadingTwo')
" call s:Link('MarkdownH3', 'oroshi_TextHeadingThree')
" call s:Link('MarkdownH4', 'oroshi_TextHeadingFour')
" call s:Link('MarkdownH5', 'oroshi_TextHeadingFive')
" call s:Link('MarkdownHeadingDelimiter', 'oroshi_TextDelimiter')
" " Code
" call s:Link('MarkdownCode', 'oroshi_CodeString')
" call s:Link('MarkdownCodeblock', 'oroshi_CodeString')
" call s:Link('MarkdownCodeDelimiter', 'oroshi_CodeString')
" " }}}
" " Pug {{{
" call s:Link('pugAttributes', 'oroshi_CodeType')
" call s:Link('pugTag', 'oroshi_CodeSymbol')
" " }}}
" " Ruby {{{
" call s:Link('rubyPseudoVariable', 'oroshi_CodeSelf')
" call s:Link('rubySymbol', 'oroshi_CodeSymbol')
" call s:Link('rubyStringDelimiter', 'oroshi_CodeString')
" call s:Link('rubyStringEscape', 'oroshi_TextSpecial')
" call s:Link('rubyInterpolation', 'oroshi_TextSpecial')
" call s:Link('rubyInterpolationDelimiter', 'oroshi_TextSpecial')
" call s:Link('rubyModule', 'oroshi_CodeType')
" call s:Link('rubyClass', 'oroshi_CodeType')
" call s:Link('rubyDefine', 'oroshi_CodeType')
" call s:Link('rubyConstant', 'oroshi_CodeClass')
" call s:Link('rubyRegexp', 'oroshi_CodeRegexp')
" call s:Link('rubyRegexpDelimiter', 'oroshi_CodeRegexpDelimiter')
" call s:Link('rubyRegexpSpecial', 'oroshi_CodeRegexp')
" call s:Link('rubyRegexpEscape', 'oroshi_TextSpecial')
" " }}}
" " Robots {{{
" call s:Link('robotsDelimiter', 'oroshi_Text')
" call s:Link('robotsAgent', 'oroshi_CodeStatement')
" call s:Link('robotsDisallow', 'oroshi_CodeType')
" call s:Link('robotsLine', 'oroshi_CodeString')
" call s:Link('robotsStar', 'oroshi_CodeSymbol')
" " }}}
" " Shell {{{
" " }}}
" " VueJS {{{
" call s:Link('vueSurroundingTag', 'oroshi_CodeStatement')
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
