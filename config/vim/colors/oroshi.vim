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
" Highlighting function {{{
" args : group, foreground, background, cterm
function! s:Highlight(group,fg,...)
  " Default highlight string we're building
  let h = 'hi! '.a:group

  " adding foreground
  let h .= ' ctermfg='.get(s:palette, a:fg)

  " adding background
  if a:0 >= 1 && strlen(a:1)
    let h .= ' ctermbg='.get(s:palette, a:1)
  endif

  " adding cterm
  if a:0 >= 2 && strlen(a:2)
    let h .= ' cterm='.a:2
  endif

  execute h
endfunction
" }}}
" Highlight linking function {{{
" args : group, linkedGroup
function! s:Link(group, linkedGroup)
  execute 'hi! def link '.a:group.' '.a:linkedGroup
endfunction
" }}}
" Color Palette {{{
let s:palette = {}
let s:palette.none          = 'none'
" Black, White and grey
let s:palette.pureblack     = 16
let s:palette.black         = 233
let s:palette.almostblack   = 234
let s:palette.darkgrey      = 235
let s:palette.grey          = 241
let s:palette.lightgrey     = 249
let s:palette.white         = 252
let s:palette.purewhite     = 255
" Red 
let s:palette.red           = 196
let s:palette.darkred       = 88
let s:palette.calmred       = 203
" Green
let s:palette.green         = 35 
let s:palette.darkgreen     = 28
let s:palette.calmgreen     = 108
" Yellow
let s:palette.yellow        = 184
let s:palette.darkyellow    = 136
let s:palette.calmyellow    = 185
" Blue
let s:palette.blue          = 69
let s:palette.darkblue      = 24
let s:palette.calmblue      = 67
" Purple
let s:palette.purple        = 171
let s:palette.darkpurple    = 133
let s:palette.calmpurple    = 141
" Orange
let s:palette.orange        = 202
let s:palette.darkorange    = 214
let s:palette.calmorange    = 209
" Pink 
let s:palette.pink          = 205
let s:palette.darkpink      = 125
let s:palette.calmpink      = 211
" }}}
" Oroshi custom styles {{{
call s:Highlight('oroshi_Debug', 'white', 'darkpurple')
call s:Highlight('oroshi_None', 'none', 'none', 'none')

call s:Highlight('oroshi_Text', 'lightgrey')
call s:Highlight('oroshi_TextBold', 'grey', 'none', 'bold')
call s:Highlight('oroshi_TextItalic', 'grey')
call s:Highlight('oroshi_TextAlmostInvisible', 'darkgrey')
call s:Highlight('oroshi_TextSpecial', 'darkyellow')
call s:Highlight('oroshi_TextCurrentLine', 'none', 'almostblack', 'none')
call s:Highlight('oroshi_TextSpellingError', 'red', 'none', 'bold,underline')
call s:Highlight('oroshi_TextHeadingOne', 'darkgreen', 'none', 'bold')
call s:Highlight('oroshi_TextHeadingTwo', 'darkgreen')
call s:Highlight('oroshi_TextHeadingThree', 'green')
call s:Highlight('oroshi_TextHeadingFour', 'calmgreen')
call s:Highlight('oroshi_TextHeadingFive', 'white')
call s:Highlight('oroshi_TextEmphasis', 'grey', 'none', 'bold')
call s:Highlight('oroshi_TextLink', 'calmred')
call s:Highlight('oroshi_TextUrl', 'calmorange')
call s:Highlight('oroshi_TextDelimiter', 'darkyellow')

call s:Highlight('oroshi_CodeClass', 'darkorange')
call s:Highlight('oroshi_CodeBoolean', 'calmorange')
call s:Highlight('oroshi_CodeChute', 'darkblue')
call s:Highlight('oroshi_CodeComment', 'grey')
call s:Highlight('oroshi_CodeConstant', 'yellow', 'none', 'bold')
call s:Highlight('oroshi_CodeFunction', 'green')
call s:Highlight('oroshi_CodeInclude', 'yellow')
call s:Highlight('oroshi_CodeNumber', 'calmblue', '', 'bold')
call s:Highlight('oroshi_CodeRegexpFlags', 'orange')
call s:Highlight('oroshi_CodeRegexpDelimiter', 'darkyellow')
call s:Highlight('oroshi_CodeRegexp', 'darkblue')
call s:Highlight('oroshi_CodeSelf', 'darkorange', '', 'bold')
call s:Highlight('oroshi_CodeStatement', 'darkgreen')
call s:Highlight('oroshi_CodeString', 'calmblue')
call s:Highlight('oroshi_CodeSymbol', 'orange')
call s:Highlight('oroshi_CodeType', 'calmred')
call s:Highlight('oroshi_CodeVariable', 'calmgreen')

call s:Highlight('oroshi_UI', 'lightgrey', 'darkgrey')
call s:Highlight('oroshi_UISecondary', 'grey')
call s:Highlight('oroshi_UIFilled', 'darkgrey', 'darkgrey')
call s:Highlight('oroshi_UIEmpty', 'black', 'black')
call s:Highlight('oroshi_UIActive', 'darkyellow', 'black', 'bold')
call s:Highlight('oroshi_UISuccess', 'darkgreen', 'darkgrey')
call s:Highlight('oroshi_UISuccessFilled', 'white', 'darkgreen')
call s:Highlight('oroshi_UINotice', 'calmpurple', 'darkgrey')
call s:Highlight('oroshi_UINoticeFilled', 'white', 'calmpurple')
call s:Highlight('oroshi_UIWarning', 'darkyellow', 'darkgrey')
call s:Highlight('oroshi_UIWarningFilled', 'white', 'darkyellow')
call s:Highlight('oroshi_UIError', 'calmred', 'darkgrey')
call s:Highlight('oroshi_UIErrorFilled', 'lightgrey', 'calmred')

call s:Highlight('oroshi_Success', 'green')
call s:Highlight('oroshi_Notice', 'calmpurple')
call s:Highlight('oroshi_Warning', 'darkyellow')
call s:Highlight('oroshi_Error', 'red', 'none', 'bold')

call s:Highlight('oroshi_DiffAdded', 'green')
call s:Highlight('oroshi_DiffRemoved', 'red')
call s:Highlight('oroshi_DiffChanged', 'calmpurple')
call s:Highlight('oroshi_DiffLine', 'darkyellow')

call s:Highlight('oroshi_GitBranch', 'orange', 'none', 'bold')

call s:Highlight('oroshi_UIModeNormal', 'black', 'darkgrey', 'bold')
call s:Highlight('oroshi_ModeNormal', 'white', 'black')
call s:Highlight('oroshi_UIModeInsert', 'darkyellow', 'darkgrey', 'bold')
call s:Highlight('oroshi_ModeInsert', 'black', 'darkyellow', 'bold')
call s:Highlight('oroshi_UIModeVisual', 'darkblue', 'darkgrey', 'bold')
call s:Highlight('oroshi_ModeVisual', 'lightgrey', 'darkblue', 'bold')
call s:Highlight('oroshi_UIModeSearch', 'orange', 'darkgrey', 'bold')
call s:Highlight('oroshi_ModeSearch', 'black', 'orange', 'bold')
" }}}

" Borders {{{
call s:Link('LineNr', 'oroshi_UISecondary')
call s:Link('SignColumn', 'oroshi_UISecondary')
call s:Link('ColorColumn', 'oroshi_UIWarning')
call s:Link('VertSplit', 'oroshi_UI')
" }}}
" Tabs {{{
call s:Link('TabLine', 'oroshi_UI')
call s:Link('TabLineFill', 'oroshi_UI')
call s:Link('TabLineSel', 'oroshi_UIActive')
" }}}
" Syntastic gutter {{{
call s:Link('SyntasticErrorSign', 'oroshi_Error')
call s:Link('SyntasticStyleErrorSign', 'oroshi_Error')
call s:Link('SyntasticWarningSign', 'oroshi_Warning')
call s:Link('SyntasticStyleWarningSign', 'oroshi_Warning')
" }}}
" GitGutter {{{
call s:Link('GitGutterAdd', 'oroshi_Success')
call s:Link('GitGutterChange', 'oroshi_Notice')
" }}}
" Status line {{{
call s:Link('StatusLine', 'oroshi_UI')
call s:Link('StatusLineNC', 'oroshi_UIFilled')
" }}}

" Cursor {{{
call s:Link('CursorLine', 'oroshi_TextCurrentLine')
call s:Link('CursorLineNr', 'oroshi_Warning')
if &term =~ "xterm"
  " Cursor in insert mode
  let &t_SI = "\<Esc>]12;#AF8700\x7"
  " Cursor in normal mode
  let &t_EI = "\<Esc>]12;#D70000\x7"
endif
" }}}
" Visual selection {{{
call s:Link('Visual', 'oroshi_ModeVisual')
" }}}
" Search {{{
call s:Link('Search', 'oroshi_ModeSearch')
call s:Link('IncSearch', 'oroshi_ModeSearch')
" }}}
" Matching parenthesis {{{
call s:Link('MatchParen', 'oroshi_UIModeSearch')
" }}}
" Folds {{{
call s:Link('Folded', 'oroshi_UI')
" }}}
" Completion menu {{{
call s:Link('Pmenu', 'oroshi_UI')
call s:Link('PmenuSbar', 'oroshi_UI')
call s:Link('PmenuSel', 'oroshi_ModeSearch')
" }}}
" " Pesky characters {{{
" call s:Highlight('ExtraWhitespace', 'darkred', 'darkred', 'bold')
" " }}}

" Text {{{
call s:Link('Noise', 'oroshi_Text')
call s:Link('NonText', 'oroshi_TextAlmostInvisible')
call s:Link('SpecialKey', 'oroshi_TextSpecial')
call s:Link('Error', 'oroshi_Error')
" Note: These styles can't be linked, they must be defined directly
call s:Highlight('Normal', 'lightgrey')
call s:Highlight('Special', 'darkyellow')
" Messages
call s:Link('WarningMsg', 'oroshi_Warning')
call s:Link('ErrorMsg', 'oroshi_Error')
" Spellchecking
call s:Link('SpellBad', 'oroshi_TextSpellingError')
call s:Link('SpellCap', 'oroshi_TextSpellingError')
" }}}
" Code {{{
call s:Link('Identifier', 'oroshi_CodeVariable')
call s:Link('Boolean', 'oroshi_CodeBoolean')
call s:Link('Operator', 'oroshi_Text')
call s:Link('Function', 'oroshi_CodeFunction')
call s:Link('Statement', 'oroshi_CodeStatement')
call s:Link('String', 'oroshi_CodeString')
call s:Link('Type', 'oroshi_CodeType')
call s:Link('Constant', 'oroshi_CodeConstant')
call s:Link('PreProc', 'oroshi_CodeInclude')
call s:Link('Number', 'oroshi_CodeNumber')
" Comments
call s:Link('Comment', 'oroshi_CodeComment')
call s:Link('Todo', 'oroshi_Warning')
call s:Link('SpecialComment', 'oroshi_Warning')
" }}}
" Diff {{{
call s:Link('diffAdded', 'oroshi_DiffAdded')
call s:Link('diffRemoved', 'oroshi_DiffRemoved')
call s:Link('DiffFile', 'oroshi_CodeComment')
call s:Link('DiffNewFile', 'oroshi_CodeComment')
call s:Link('DiffLine', 'oroshi_DiffLine')
call s:Link('diffSubname', 'oroshi_Normal')
call s:Link('diffBDiffer', 'oroshi_CodeInclude')
" }}}

" Ansible {{{
call s:Link('jinjaVariable', 'oroshi_TextSpecial')
call s:Link('jinjaOperator', 'oroshi_TextSpecial')
call s:Link('jinjaAttribute', 'oroshi_TextSpecial')
call s:Link('jinjaVarDelim', 'oroshi_TextSpecial')
call s:Link('ansibleRepeat', 'oroshi_CodeChute')
call s:Link('ansibleConditional', 'oroshi_CodeStatement')
" }}}
" CSS {{{
call s:Link('sassClass', 'oroshi_CodeFunction')
call s:Link('sassClassChar', 'oroshi_CodeFunction')
call s:Link('sassAmpersand', 'oroshi_CodeSelf')
call s:Link('scssSelectorName', 'oroshi_CodeVariable')
call s:Link('scssProperty', 'oroshi_CodeSymbol')
call s:Link('scssParameterList', 'oroshi_CodeSymbol')
call s:Link('cssAttrComma', 'oroshi_Text')
call s:Link('cssAttr', 'oroshi_CodeSymbol')
call s:Link('cssBraces', 'oroshi_Text')
call s:Link('cssColor', 'oroshi_CodeNumber')
call s:Link('cssClassName', 'oroshi_CodeVariable')
call s:Link('cssClassNameDot', 'oroshi_TextSpecial')
call s:Link('cssFunction', 'oroshi_CodeSymbol')
call s:Link('cssImportant', 'oroshi_Error')
call s:Link('cssIncludeKeyword', 'oroshi_CodeInclude')
call s:Link('cssMedia', 'oroshi_CodeInclude')
call s:Link('cssProp', 'oroshi_CodeType')
call s:Link('cssPseudoClassId', 'oroshi_CodeVariable')
call s:Link('cssUnitDecorators', 'oroshi_CodeNumber')
call s:Link('cssValueLength', 'oroshi_CodeNumber')
call s:Link('cssVendorPrefixProp', 'oroshi_CodeType')
" }}}
" Git {{{
call s:Link('gitcommitDiff', 'oroshi_DiffChanged')
call s:Link('gitcommitSummary', 'oroshi_Text')
call s:Link('gitcommitBranch', 'oroshi_GitBranch')
call s:Link('gitcommitHeader', 'oroshi_CodeComment')
call s:Link('gitcommitSelectedFile', 'oroshi_DiffChanged')
call s:Link('gitcommitUntrackedFile', 'oroshi_Text')
call s:Link('gitcommitOverflow', 'oroshi_Error')
call s:Link('gitcommitBlank', 'oroshi_Error')
call s:Link('gitconfigVariable', 'oroshi_CodeType')
call s:Link('gitconfigAssignment', 'oroshi_CodeString')
" }}}
" HTML {{{
call s:Link('htmlTag', 'oroshi_CodeStatement')
call s:Link('htmlTagName', 'oroshi_CodeStatement')
call s:Link('htmlEndTag', 'oroshi_CodeStatement')
call s:Link('htmlSpecialTagName', 'oroshi_CodeStatement')
call s:Link('htmlTagN', 'oroshi_CodeStatement')
call s:Link('htmlH1', 'oroshi_Text')
call s:Link('htmlItalic', 'oroshi_Text')
call s:Link('htmlLink', 'oroshi_Text')
call s:Link('htmlTitle', 'oroshi_Text')
" }}}
" JavaScript {{{
call s:Link('jsExceptions', 'oroshi_Warning')
call s:Link('jsTemplateExpression', 'oroshi_TextSpecial')
call s:Link('jsTemplateBraces', 'oroshi_TextSpecial')
call s:Link('jsFuncCall', 'oroshi_CodeFunction')
call s:Link('jsGlobalObjects', 'oroshi_CodeClass')
" }}}
" Markdown {{{
call s:Link('MarkdownRule', 'oroshi_TextDelimiter')
call s:Link('MarkdownBold', 'oroshi_TextBold')
call s:Link('MarkdownItalic', 'oroshi_TextItalic')
call s:Link('MarkdownListMarker', 'oroshi_Text')
" Links
call s:Link('markdownLinkDelimiter', 'oroshi_TextLink')
call s:Link('markdownIdDeclaration', 'oroshi_TextLink')
call s:Link('markdownLinkTextDelimiter', 'oroshi_TextLink')
call s:Link('markdownLinkText', 'oroshi_TextLink')
call s:Link('markdownUrl', 'oroshi_TextUrl')
call s:Link('markdownId', 'oroshi_TextUrl')
call s:Link('markdownIdDelimiter', 'oroshi_TextUrl')
" Headings
call s:Link('MarkdownH1', 'oroshi_TextHeadingOne')
call s:Link('MarkdownH2', 'oroshi_TextHeadingTwo')
call s:Link('MarkdownH3', 'oroshi_TextHeadingThree')
call s:Link('MarkdownH4', 'oroshi_TextHeadingFour')
call s:Link('MarkdownH5', 'oroshi_TextHeadingFive')
call s:Link('MarkdownHeadingDelimiter', 'oroshi_TextDelimiter')
" Code
call s:Link('MarkdownCode', 'oroshi_CodeString')
call s:Link('MarkdownCodeblock', 'oroshi_CodeString')
call s:Link('MarkdownCodeDelimiter', 'oroshi_CodeString')
" }}}
" Pug {{{
call s:Link('pugAttributes', 'oroshi_CodeType')
call s:Link('pugTag', 'oroshi_CodeSymbol')
" }}}
" Ruby {{{
call s:Link('rubyPseudoVariable', 'oroshi_CodeSelf')
call s:Link('rubySymbol', 'oroshi_CodeSymbol')
call s:Link('rubyStringDelimiter', 'oroshi_CodeString')
call s:Link('rubyStringEscape', 'oroshi_TextSpecial')
call s:Link('rubyInterpolation', 'oroshi_TextSpecial')
call s:Link('rubyInterpolationDelimiter', 'oroshi_TextSpecial')
call s:Link('rubyModule', 'oroshi_CodeType')
call s:Link('rubyClass', 'oroshi_CodeType')
call s:Link('rubyDefine', 'oroshi_CodeType')
call s:Link('rubyConstant', 'oroshi_CodeClass')
call s:Link('rubyRegexp', 'oroshi_CodeRegexp')
call s:Link('rubyRegexpDelimiter', 'oroshi_CodeRegexpDelimiter')
call s:Link('rubyRegexpSpecial', 'oroshi_CodeRegexp')
call s:Link('rubyRegexpEscape', 'oroshi_TextSpecial')
" }}}
" Robots {{{
call s:Link('robotsDelimiter', 'oroshi_Text')
call s:Link('robotsAgent', 'oroshi_CodeStatement')
call s:Link('robotsDisallow', 'oroshi_CodeType')
call s:Link('robotsLine', 'oroshi_CodeString')
call s:Link('robotsStar', 'oroshi_CodeSymbol')
" }}}
" Shell {{{
call s:Link('shOption', 'oroshi_CodeType')
call s:Link('shDerefSimple', 'oroshi_CodeVariable')
call s:Link('zshDeref', 'oroshi_CodeVariable')
call s:Link('zshShortDeref', 'oroshi_CodeVariable')
call s:Link('zshRedir', 'oroshi_TextSpecial')
call s:Link('zshSubst', 'oroshi_CodeVariable')
call s:Link('zshOldSubst', 'oroshi_CodeVariable')
call s:Link('zshSubstDelim', 'oroshi_CodeVariable')
call s:Link('shCommandSub', 'oroshi_CodeVariable')
call s:Link('shCmdSubRegion', 'oroshi_CodeVariable')
call s:Link('shQuote', 'oroshi_CodeString')
" }}}
" VueJS {{{
call s:Link('vueSurroundingTag', 'oroshi_CodeStatement')
" }}}
" Vim {{{
call s:Link('vimCommentTitle', 'oroshi_Warning')
call s:Link('vimParenSep', 'oroshi_Text')
call s:Link('vimIsCommand', 'oroshi_CodeVariable')
" Option keys
call s:Link('vimOption', 'oroshi_CodeSymbol')
call s:Link('vimFTOption', 'oroshi_CodeSymbol')
call s:Link('vimHiClear', 'oroshi_CodeSymbol')
call s:Link('vimSynType', 'oroshi_CodeSymbol')
call s:Link('vimAutoEvent', 'oroshi_CodeSymbol')
call s:Link('vimNormCmds', 'oroshi_CodeSymbol')
call s:Link('vimMapLhs', 'oroshi_CodeSymbol')
" Option values
call s:Link('vimSet', 'oroshi_CodeString')
call s:Link('vimSetEqual', 'oroshi_CodeString')
call s:Link('vimMapRhs', 'oroshi_CodeString')
" Functions
call s:Link('vimFunction', 'oroshi_CodeFunction')
call s:Link('vimUserFunc', 'oroshi_CodeFunction')
call s:Link('vimFuncKey', 'oroshi_CodeType')
" Normal commands
call s:Link('vimNormCmds', 'oroshi_Text')
call s:Link('vimUserAttrb', 'oroshi_Text')
" Special keys
call s:Link('vimMapMod', 'oroshi_TextSpecial')
call s:Link('vimMapModKey', 'oroshi_TextSpecial')
call s:Link('vimAutoCmdSfxList', 'oroshi_TextSpecial')
call s:Link('vimCtrlCharMod', 'oroshi_TextSpecial')
" Regexps
call s:Link('vimSubstFlags', 'oroshi_CodeRegexpFlags')
call s:Link('vimAddress', 'oroshi_CodeRegexpFlags')
call s:Link('vimSubst1', 'oroshi_CodeRegexpFlags')
call s:Link('vimSubstPat', 'oroshi_CodeRegexp')
call s:Link('vimSubstRep4', 'oroshi_CodeRegexp')
call s:Link('vimSubstDelim', 'oroshi_CodeRegexpDelimiter')
" Vim Help
call s:Link('helpHeader', 'oroshi_TextHeadingOne')
call s:Link('helpVim', 'oroshi_TextHeadingOne')
call s:Link('helpNotVi', 'oroshi_Notice')
call s:Link('helpSectionDelim', 'oroshi_TextDelimiter')
call s:Link('helpSpecial', 'oroshi_CodeString')
call s:Link('helpHyperTextEntry', 'oroshi_TextLink')
call s:Link('helpExample', 'oroshi_CodeString')
call s:Link('helpOption', 'oroshi_CodeSymbol')
" }}}
" YAML {{{
call s:Link('yamlBlockMappingKey', 'oroshi_CodeType')
call s:Link('yamlBlockCollectionItemStart', 'oroshi_Text')
call s:Link('yamlDelimiter', 'oroshi_Text')
call s:Link('yamlKeyValueDelimiter', 'oroshi_Text')
call s:Link('yamlKey', 'oroshi_CodeType')
call s:Link('yamlNull', 'yamlScalar')
call s:Link('yamlPlainScalar', 'oroshi_CodeStatement')
call s:Link('yamlAlias', 'oroshi_CodeInclude')
call s:Highlight('yamlAnchor', 'darkyellow', 'none', 'bold')
call s:Highlight('yamlBlockMappingMerge', 'darkyellow', 'none', 'bold')
" }}}
" XML {{{
call s:Link('xmlAttribPunct', 'oroshi_CodeStatement')
call s:Link('xmlNamespace', 'oroshi_CodeStatement')
call s:Link('xmlTag', 'oroshi_CodeStatement')
call s:Link('xmlTagName', 'oroshi_CodeStatement')
call s:Link('xmlEndTag', 'oroshi_CodeStatement')
" }}}

" CtrlP {{{
call s:Highlight('oroshi_UIModeCtrlPPrompt', 'black', 'calmred', 'bold')
call s:Highlight('oroshi_UIModeCtrlPArrow', 'calmred', 'darkgrey')
call s:Highlight('oroshi_UIModeCtrlPGutter', 'calmred', 'calmred')
call s:Highlight('oroshi_UIModeCtrlPPrePrompt', 'calmred', 'black')
call s:Highlight('oroshi_ModeCtrlPPromptText', 'white', 'black', 'bold')
call s:Highlight('oroshi_ModeCtrlPPromptTextCursor', 'white', 'red', 'bold')
call s:Highlight('oroshi_ModeCtrlPHighlight', 'calmred', 'none')

call s:Link('CtrlPLinePre', 'oroshi_UIModeCtrlPGutter')
call s:Link('CtrlPPrtBase', 'oroshi_UIModeCtrlPPrePrompt')
call s:Link('CtrlPPrtText', 'oroshi_ModeCtrlPPromptText')
call s:Link('CtrlPPrtCursor', 'oroshi_ModeCtrlPPromptTextCursor')
call s:Link('CtrlPMatch', 'oroshi_ModeCtrlPHighlight')
" }}}
" CtrlF {{{
call s:Highlight('oroshi_UIModeCtrlF', 'purewhite')
call s:Highlight('oroshi_ModeCtrlF', 'purewhite')
call s:Highlight('oroshi_ModeCtrlFMatch', 'calmred')
" Note: The Search highlight is used in the quickfix window for the current
" element. This method is called whenever the quickfix window got focus and
" change the Search coloring, and revert it when losing focus.
function! UpdateSearchColoring(...)
  " buftype is either empty or 'quickfix', and can be specifed as an argument
  let buftype = (a:0 == 1) ? a:1 : &buftype

  if buftype ==# 'quickfix'
    " Removing coloring in quickfix
    hi clear Search
    hi link Search NONE
  else
    " Reverting initial coloring
    call s:Link('Search', 'oroshi_ModeSearch')
  endif
endfunction

augroup quickfix_coloring
  au!
  au BufWinEnter quickfix call UpdateSearchColoring('quickfix')
  au WinEnter * call UpdateSearchColoring()
augroup END
" }}}
