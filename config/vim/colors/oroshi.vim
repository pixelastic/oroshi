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
function! s:Highlight(group,fg,...)
  " Default highlight string we're building
  let h = 'hi! '.a:group

  " adding foreground
  if strlen(a:fg)
    let h .= ' ctermfg='.get(s:color, a:fg)
  endif

  " adding background
  if a:0 >= 1 && strlen(a:1)
    let h .= ' ctermbg='.get(s:color, a:1)
  endif

  " adding cterm
  if a:0 >= 2 && strlen(a:2)
    let h .= ' cterm='.a:2
  endif

  execute h
endfunction
" }}}
" " Highlight linking function {{{
" " args : group, linkedGroup
" function! s:Link(group, linkedGroup)
"   execute 'hi! def link '.a:group.' '.a:linkedGroup
" endfunction
" " }}}
" " Oroshi custom styles {{{
" call s:Highlight('oroshi_Debug', 'white', 'darkpurple')
" call s:Highlight('oroshi_None', 'none', 'none', 'none')

" call s:Highlight('oroshi_Text', 'gray4')
" call s:Highlight('oroshi_TextBold', 'gray', 'none', 'bold')
" call s:Highlight('oroshi_TextItalic', 'gray')
" call s:Highlight('oroshi_TextAlmostInvisible', 'gray8')
" call s:Highlight('oroshi_TextSpecial', 'yellow8')
" call s:Highlight('oroshi_TextSpellingError', 'red', 'none', 'bold,underline')
" call s:Highlight('oroshi_TextHeadingOne', 'green8', 'none', 'bold')
" call s:Highlight('oroshi_TextHeadingTwo', 'green8')
" call s:Highlight('oroshi_TextHeadingThree', 'green')
" call s:Highlight('oroshi_TextHeadingFour', 'green5')
" call s:Highlight('oroshi_TextHeadingFive', 'white')
" call s:Highlight('oroshi_TextEmphasis', 'gray', 'none', 'bold')
" call s:Highlight('oroshi_TextLink', 'red5')
" call s:Highlight('oroshi_TextUrl', 'orange5')
" call s:Highlight('oroshi_TextDelimiter', 'yellow8')

" call s:Highlight('oroshi_CodeClass', 'orange8')
" call s:Highlight('oroshi_CodeBoolean', 'orange5')
" call s:Highlight('oroshi_CodeChute', 'blue8')
" call s:Highlight('oroshi_CodeComment', 'gray')
" call s:Highlight('oroshi_CodeConstant', 'yellow', 'none', 'bold')
" call s:Highlight('oroshi_CodeFunction', 'green')
" call s:Highlight('oroshi_CodeInclude', 'yellow')
" call s:Highlight('oroshi_CodeNumber', 'blue5', '', 'bold')
" call s:Highlight('oroshi_CodeRegexpFlags', 'orange')
" call s:Highlight('oroshi_CodeRegexpDelimiter', 'yellow8')
" call s:Highlight('oroshi_CodeRegexp', 'blue8')
" call s:Highlight('oroshi_CodeSelf', 'orange8', '', 'bold')
" call s:Highlight('oroshi_CodeStatement', 'green8')
" call s:Highlight('oroshi_CodeString', 'blue5')
" call s:Highlight('oroshi_CodeSymbol', 'orange')
" call s:Highlight('oroshi_CodeType', 'red5')
" call s:Highlight('oroshi_CodeVariable', 'green5')

" call s:Highlight('oroshi_UI', 'gray4', 'gray8')
" call s:Highlight('oroshi_UISecondary', 'gray')
" call s:Highlight('oroshi_UIFilled', 'gray8', 'gray8')
" call s:Highlight('oroshi_UIEmpty', 'black', 'black')
" call s:Highlight('oroshi_UIActive', 'yellow8', 'black', 'bold')
" call s:Highlight('oroshi_UISuccess', 'green8', 'gray8')
" call s:Highlight('oroshi_UISuccessFilled', 'white', 'green8')
" call s:Highlight('oroshi_UINotice', 'purple5', 'gray8')
" call s:Highlight('oroshi_UINoticeFilled', 'white', 'purple5')
" call s:Highlight('oroshi_UIWarning', 'yellow8', 'gray8')
" call s:Highlight('oroshi_UIWarningFilled', 'white', 'yellow8')
" call s:Highlight('oroshi_UIError', 'red5', 'gray8')
" call s:Highlight('oroshi_UIErrorFilled', 'gray4', 'red5')

" call s:Highlight('oroshi_Success', 'green')
" call s:Highlight('oroshi_Notice', 'purple5')
" call s:Highlight('oroshi_Warning', 'yellow8')
" call s:Highlight('oroshi_Error', 'red', 'none', 'bold')

" call s:Highlight('oroshi_DiffAdded', 'green')
" call s:Highlight('oroshi_DiffRemoved', 'red')
" call s:Highlight('oroshi_DiffChanged', 'purple5')
" call s:Highlight('oroshi_DiffLine', 'yellow8')

" call s:Highlight('oroshi_GitBranch', 'orange', 'none', 'bold')

" call s:Highlight('oroshi_UIModeNormal', 'black', 'gray8')
" call s:Highlight('oroshi_ModeNormal', 'white', 'black')
" call s:Highlight('oroshi_UIModeInsert', 'yellow8', 'gray8')
" call s:Highlight('oroshi_ModeInsert', 'black', 'yellow8', 'bold')
" call s:Highlight('oroshi_UIModeVisual', 'blue8', 'gray8')
" call s:Highlight('oroshi_ModeVisual', 'gray4', 'blue8', 'bold')
" call s:Highlight('oroshi_UIModeSearch', 'orange', 'gray8')
" call s:Highlight('oroshi_ModeSearch', 'black', 'orange', 'bold')
" " }}}

" Text {{{
call s:Highlight('Boolean', 'orange5')
call s:Highlight('Comment', 'gray')
call s:Highlight('Constant', 'yellow', 'none', 'bold')
call s:Highlight('Error', 'red', '', 'bold')
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
call s:Highlight('Todo', 'yellow')
call s:Highlight('Type', 'red5')
call s:Highlight('Title', 'yellow')
" }}}
" UI {{{
" Borders {{{
call s:Highlight('LineNr', 'gray')
call s:Highlight('ColorColumn', 'yellow', 'gray9')
call s:Highlight('SignColumn', 'white', 'black', 'none')
call s:Highlight('VertSplit', 'gray9', 'gray9', 'bold')
" }}}
" Tabs {{{
call s:Highlight('TabLine', 'gray4', 'gray9', 'none')
call s:Highlight('TabLineFill', 'gray8', 'gray9', 'none')
call s:Highlight('TabLineSel', 'yellow', 'gray8', 'bold')
" }}}
" Cursor {{{
call s:Highlight('CursorLine', '', 'gray9', 'none')
call s:Highlight('CursorLineNr', 'yellow', '', 'bold')
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
call s:Highlight('Search', 'white', 'orange', 'none')
call s:Highlight('IncSearch', 'white', 'orange', 'none')
" }}}
" Syntastic gutter {{{
call s:Highlight('SyntasticErrorSign', 'red')
call s:Highlight('SyntasticStyleErrorSign', 'red')
call s:Highlight('SyntasticWarningSign', 'yellow')
call s:Highlight('SyntasticStyleWarningSign', 'yellow')
" }}}
" GitGutter {{{
call s:Highlight('GitGutterChange', 'purple')
call s:Highlight('GitGutterAdd', 'green')
" }}}
" Status line {{{
call s:Highlight('StatusLine', 'gray4', 'gray8', 'none')
call s:Highlight('StatusLineNC', '', 'gray8', 'none')
call s:Highlight('StatusLineModeUnknown', 'white', 'red')
call s:Highlight('StatusLineModeUnknownSeparator', 'red', 'white')
call s:Highlight('StatusLineModeNormal', 'white', 'black')
call s:Highlight('StatusLineModeNormalSeparator', 'black', 'gray8')
call s:Highlight('StatusLineModeInsert', 'black', 'yellow', 'bold')
call s:Highlight('StatusLineModeInsertSeparator', 'yellow', 'gray8')
call s:Highlight('StatusLineModeVisual', 'white', 'blue', 'bold')
call s:Highlight('StatusLineModeVisualSeparator', 'blue', 'gray8')
call s:Highlight('StatusLineModeSearch', 'black', 'orange', 'bold')
call s:Highlight('StatusLineModeSearchSeparator', 'orange', 'gray8')
call s:Highlight('StatusLinePath', 'green', 'gray8', 'bold')
call s:Highlight('StatusLinePathModified', 'purple4', 'gray8')
call s:Highlight('StatusLinePathReadonly', 'red', 'gray8')
call s:Highlight('StatusLineGitClean', 'green', 'gray8')
call s:Highlight('StatusLineGitDirty', 'red', 'gray8', 'bold')
call s:Highlight('StatusLineGitStaged', 'purple4', 'gray8')
call s:Highlight('StatusLineSyntasticError', 'red', 'gray8')
call s:Highlight('StatusLineFileFormatError', 'red', 'gray8')
call s:Highlight('StatusLineFileEncodingError', 'red', 'gray8')
call s:Highlight('StatusLineRight', 'gray4', 'gray8', 'none')
" }}}
" Matching parenthesis {{{
call s:Highlight('MatchParen', 'white', 'teal9')
" }}}
" " Completion menu {{{
" call s:Link('Pmenu', 'oroshi_UI')
" call s:Link('PmenuSbar', 'oroshi_UI')
" call s:Link('PmenuSel', 'oroshi_ModeSearch')
" " }}}
" " Pesky characters {{{
" call s:Highlight('ExtraWhitespace', 'darkred', 'darkred', 'bold')
" " }}}
" " CtrlP {{{
" call s:Highlight('oroshi_UIModeCtrlPPrompt', 'black', 'red5', 'bold')
" call s:Highlight('oroshi_UIModeCtrlPArrow', 'red5', 'gray8')
" call s:Highlight('oroshi_UIModeCtrlPGutter', 'red5', 'red5')
" call s:Highlight('oroshi_UIModeCtrlPPrePrompt', 'red5', 'black')
" call s:Highlight('oroshi_ModeCtrlPPromptText', 'white', 'black', 'bold')
" call s:Highlight('oroshi_ModeCtrlPPromptTextCursor', 'white', 'red', 'bold')
" call s:Highlight('oroshi_ModeCtrlPHighlight', 'red5', 'none')

" call s:Link('CtrlPLinePre', 'oroshi_UIModeCtrlPGutter')
" call s:Link('CtrlPPrtBase', 'oroshi_UIModeCtrlPPrePrompt')
" call s:Link('CtrlPPrtText', 'oroshi_ModeCtrlPPromptText')
" call s:Link('CtrlPPrtCursor', 'oroshi_ModeCtrlPPromptTextCursor')
" call s:Link('CtrlPMatch', 'oroshi_ModeCtrlPHighlight')
" " }}}
" " CtrlF {{{
" call s:Highlight('oroshi_UIModeCtrlF', 'purewhite')
" call s:Highlight('oroshi_ModeCtrlF', 'purewhite')
" call s:Highlight('oroshi_ModeCtrlFMatch', 'red5')
" " Note: The Search highlight is used in the quickfix window for the current
" " element. This method is called whenever the quickfix window got focus and
" " change the Search coloring, and revert it when losing focus.
" function! UpdateSearchColoring(...)
"   " buftype is either empty or 'quickfix', and can be specifed as an argument
"   let buftype = (a:0 == 1) ? a:1 : &buftype

"   if buftype ==# 'quickfix'
"     " Removing coloring in quickfix
"     hi clear Search
"     hi link Search NONE
"   else
"     " Reverting initial coloring
"     call s:Link('Search', 'oroshi_ModeSearch')
"   endif
" endfunction

" augroup quickfix_coloring
"   au!
"   au BufWinEnter quickfix call UpdateSearchColoring('quickfix')
"   au WinEnter * call UpdateSearchColoring()
" augroup END
" " }}}
" Messages {{{
call s:Highlight('WarningMsg', 'yellow8')
call s:Highlight('ErrorMsg', 'red', '', 'bold')
" }}}
" Spellchecking {{{
call s:Highlight('SpellBad', 'red', 'none', 'bold,underline')
call s:Highlight('SpellCap', 'red', 'none', 'bold,underline')
" }}}
" " Diff {{{
" call s:Link('diffAdded', 'oroshi_DiffAdded')
" call s:Link('diffRemoved', 'oroshi_DiffRemoved')
" call s:Link('DiffFile', 'oroshi_CodeComment')
" call s:Link('DiffNewFile', 'oroshi_CodeComment')
" call s:Link('DiffLine', 'oroshi_DiffLine')
" call s:Link('diffSubname', 'oroshi_Normal')
" call s:Link('diffBDiffer', 'oroshi_CodeInclude')
" " }}}
" }}}

" HTML {{{
call s:Highlight('htmlTag', 'teal7')
call s:Highlight('htmlTagName', 'green7')
" }}}
" JavaScript {{{
call s:Highlight('jsArrowFunction', 'teal7')
call s:Highlight('jsFuncArgs', 'indigo5')
call s:Highlight('jsVariableDef', 'indigo4')
call s:Highlight('jsThis', 'indigo4')
call s:Highlight('jsDestructuringBlock', 'indigo5')
call s:Highlight('jsTemplateExpression', 'indigo4')
call s:Highlight('jsTemplateBraces', 'indigo4')
call s:Highlight('jsStorageClass', 'green7')
call s:Highlight('jsAsyncKeyword', 'green7')
call s:Highlight('jsForAwait', 'green7')
call s:Highlight('jsTemplateString', 'blue6')
call s:Highlight('jsBooleanFalse', 'red5', '', 'bold')
call s:Highlight('jsBooleanTrue', 'green', '', 'bold')
call s:Highlight('jsNull', 'pink5', '', 'bold')
call s:Highlight('jsUndefined', 'gray4', '', 'bold')
call s:Highlight('jsRegexpString', 'blue4')
call s:Highlight('jsRegexpGroup', 'green')
call s:Highlight('jsRegexpBoundary', 'orange')
call s:Highlight('jsRegexpQuantifier', 'orange')
call s:Highlight('jsRegexpOr', 'orange')
" }}}
" Markdown {{{
call s:Highlight('markdownCode', 'blue5')
call s:Highlight('markdownCodeDelimiter', 'blue5')
call s:Highlight('markdownLinkTextDelimiter', 'indigo8')
call s:Highlight('markdownLinkText', 'indigo5', '', 'underline')
call s:Highlight('markdownLinkDelimiter', 'yellow8')
call s:Highlight('markdownUrl', 'yellow')
call s:Highlight('markdownRule', 'teal')
call s:Highlight('markdownH1', 'green4', '', 'bold')
call s:Highlight('markdownH2', 'green5', '', 'bold')
call s:Highlight('markdownH3', 'green6', '', 'bold')
call s:Highlight('markdownH4', 'green7', '', 'bold')
call s:Highlight('markdownH5', 'green8', '', 'bold')
call s:Highlight('markdownH6', 'green9', '', 'bold')
" }}}
" Pug {{{
call s:Highlight('pugClassChar', 'teal7')
call s:Highlight('pugJavascriptChar', 'teal7')
call s:Highlight('pugJavascriptOutputChar', 'teal7')
call s:Highlight('pugAttributes', 'red5')
call s:Highlight('pugAngular2', 'blue4', '', 'italic,bold')
call s:Highlight('pugScriptLoopKeywords', 'pink4')
call s:Highlight('pugTag', 'yellow')
" }}}
" Shell {{{
call s:Highlight('shQuote', 'blue5')
call s:Highlight('shSet', 'green7')
call s:Highlight('shStatement', 'yellow7')
call s:Highlight('shSetOption', 'indigo4')
call s:Highlight('shOption', 'indigo4')
call s:Highlight('shVarAssign', 'teal7')
call s:Highlight('shDerefSimple', 'indigo4')
call s:Highlight('shDerefVar', 'indigo4')
" }}}
" Vim {{{
call s:Highlight('vimFunc', 'yellow6')
call s:Highlight('vimFunction', 'yellow6')
call s:Highlight('vimUserFunc', 'yellow6')
call s:Highlight('vimParenSep', 'teal7')
call s:Highlight('vimOperParen', 'teal7')
call s:Highlight('vimCommand', 'green7')
call s:Highlight('vimOption', 'indigo4')
" }}}
" Yaml {{{
call s:Highlight('yamlKeyValueDelimiter', 'teal7')
call s:Highlight('yamlBlockCollectionItemStart', 'teal7')
call s:Highlight('yamlPlainScalar', 'blue5')
call s:Highlight('yamlAlias', 'yellow6')
call s:Highlight('yamlFlowString', 'blue5')
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
" " Git {{{
" call s:Link('gitcommitDiff', 'oroshi_DiffChanged')
" call s:Link('gitcommitSummary', 'oroshi_Text')
" call s:Link('gitcommitBranch', 'oroshi_GitBranch')
" call s:Link('gitcommitHeader', 'oroshi_CodeComment')
" call s:Link('gitcommitSelectedFile', 'oroshi_DiffChanged')
" call s:Link('gitcommitUntrackedFile', 'oroshi_Text')
" call s:Link('gitcommitOverflow', 'oroshi_Error')
" call s:Link('gitcommitBlank', 'oroshi_Error')
" call s:Link('gitconfigVariable', 'oroshi_CodeType')
" call s:Link('gitconfigAssignment', 'oroshi_CodeString')
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
" " JavaScript {{{
" " Blue: Strings and numbers
" " Gray: Comments
" " Green: Modifiers (const, async, etc)
" " Indigo: if, return, while
" " Orange: Variables
" " Pink: ???
" " Purple: ???
" " Red: ???
" " Teal: Punctuation
" " Yellow: Functions
" " Punctuation
" " call s:Highlight('jsArrowFunction', 'teal7')
" " call s:Highlight('jsBrackets', 'teal7')
" " call s:Highlight('jsFuncBraces', 'teal7')
" " call s:Highlight('jsFuncParens', 'teal7')
" " call s:Highlight('jsIfElseBraces', 'teal7')
" " call s:Highlight('jsObjectBraces', 'teal7')
" " call s:Highlight('jsNoise', 'teal7')
" " call s:Highlight('jsOperator', 'teal7')
" " call s:Highlight('jsParens', 'teal7')
" " call s:Highlight('jsDot', 'teal7')
" " " if, return, while
" " call s:Highlight('jsConditional', 'indigo')
" " call s:Highlight('jsReturn', 'indigo', '', 'bold')
" " call s:Highlight('jsTernaryIfOperator', 'indigo', '', 'bold')
" " " true, false, undefined, null
" " call s:Highlight('jsBooleanFalse', 'red6', '', 'bold')
" " call s:Highlight('jsBooleanTrue', 'green', '', 'bold')
" " call s:Highlight('jsNull', 'yellow', '', 'bold')
" " call s:Highlight('jsUndefined', 'purple', '', 'bold')
" " " Strings
" " call s:Highlight('jsTemplateBraces', 'orange')
" " call s:Highlight('jsTemplateExpression', 'orange')
" " call s:Highlight('jsTemplateString', 'blue4')
" " call s:Highlight('jsString', 'blue6')
" " " Functions
" " call s:Highlight('jsAsyncKeyword', 'green8')
" " call s:Highlight('jsForAwait', 'green8', '', 'bold')
" " call s:Highlight('jsFuncCall', 'yellow')
" " call s:Highlight('jsFuncName', 'yellow', '', 'bold')
" " call s:Highlight('jsFunction', 'green8')
" " call s:Highlight('jsGlobalNodeObjects', 'yellow', '', 'bold') " require, module
" " call s:Highlight('jsGlobalObjects', 'yellow', '', 'bold') " console, window
" " " Variables
" " call s:Highlight('jsVariableDef', 'orange')
" " call s:Highlight('jsFuncArgs', 'orange')
" " call s:Highlight('jsObjectKey', 'orange8')
" " call s:Highlight('jsStorageClass', 'green8') " const, var, let

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
" call s:Link('shOption', 'oroshi_CodeType')
" call s:Link('shDerefSimple', 'oroshi_CodeVariable')
" call s:Link('zshDeref', 'oroshi_CodeVariable')
" call s:Link('zshShortDeref', 'oroshi_CodeVariable')
" call s:Link('zshRedir', 'oroshi_TextSpecial')
" call s:Link('zshSubst', 'oroshi_CodeVariable')
" call s:Link('zshOldSubst', 'oroshi_CodeVariable')
" call s:Link('zshSubstDelim', 'oroshi_CodeVariable')
" call s:Link('shCommandSub', 'oroshi_CodeVariable')
" call s:Link('shCmdSubRegion', 'oroshi_CodeVariable')
" call s:Link('shQuote', 'oroshi_CodeString')
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

