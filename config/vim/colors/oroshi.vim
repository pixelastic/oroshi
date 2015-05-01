" Name:         Oroshi
" Maintainer:   Tim Carry <tim@pixelastic.com>
" "C'est parce qu'il y a 6 matières, c'est ca ?"

" Initialization {{{
set t_Co=256
set background=dark
hi clear
if exists("syntax_on")
   syntax reset
endif
let g:colors_name = "oroshi"
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
let s:palette.lightgrey     = 250
let s:palette.white         = 252
let s:palette.purewhite     = 255
" Blue
let s:palette.blue          = 69
let s:palette.darkblue      = 24
let s:palette.calmblue      = 67
" Green
let s:palette.green         = 35 
let s:palette.darkgreen     = 28
let s:palette.calmgreen     = 108
" Orange
let s:palette.orange        = 202
let s:palette.darkorange    = 214
let s:palette.calmorange    = 209
" Pink 
let s:palette.pink          = 205
let s:palette.darkpink      = 125
let s:palette.calmpink      = 211
" Purple
let s:palette.purple        = 171
let s:palette.darkpurple    = 133
let s:palette.calmpurple    = 141
" Red 
let s:palette.red           = 160
let s:palette.darkred       = 88
let s:palette.calmred       = 203
" Yellow
let s:palette.yellow        = 184
let s:palette.darkyellow    = 136
let s:palette.calmyellow    = 185
" }}}
" Oroshi custom styles {{{
call s:Highlight('oroshi_Debug', 'white', 'darkpurple')

call s:Highlight('oroshi_Text', 'white', 'black')
call s:Highlight('oroshi_TextHighlight', 'none', 'almostblack', 'none')
call s:Highlight('oroshi_TextSecondary', 'grey', 'black')
call s:Highlight('oroshi_TextTertiary', 'darkgrey', 'black')
call s:Highlight('oroshi_TextSpellingError', 'red', 'none', 'bold,underline')

call s:Highlight('oroshi_UI', 'lightgrey', 'darkgrey')
call s:Highlight('oroshi_UIFilled', 'darkgrey', 'darkgrey')
call s:Highlight('oroshi_UIActive', 'white', 'black', 'bold')
call s:Highlight('oroshi_UISuccess', 'darkgreen', 'darkgrey')
call s:Highlight('oroshi_UISuccessFilled', 'darkgreen', 'darkgreen')
call s:Highlight('oroshi_UINotice', 'calmpurple', 'darkgrey')
call s:Highlight('oroshi_UINoticeFilled', 'calmpurple', 'calmpurple')
call s:Highlight('oroshi_UIWarning', 'darkyellow', 'darkgrey')
call s:Highlight('oroshi_UIWarningFilled', 'darkyellow', 'darkyellow')
call s:Highlight('oroshi_UIError', 'red', 'darkgrey')
call s:Highlight('oroshi_UIErrorFilled', 'red', 'red')

call s:Highlight('oroshi_Success', 'green')
call s:Highlight('oroshi_Notice', 'calmpurple')
call s:Highlight('oroshi_Warning', 'darkyellow')
call s:Highlight('oroshi_Error', 'red')

call s:Highlight('oroshi_ModeNormal', 'white', 'black')
call s:Highlight('oroshi_ModeInsert', 'black', 'darkyellow', 'bold')
call s:Highlight('oroshi_ModeVisual', 'lightgrey', 'darkblue', 'bold')
call s:Highlight('oroshi_ModeSearch', 'black', 'orange', 'bold')
call s:Highlight('oroshi_ModeCtrlP', 'black', 'calmred', 'bold')
call s:Highlight('oroshi_ModeCtrlF', 'black', 'darkgreen', 'bold')
call s:Highlight('oroshi_UIModeNormal', 'black', 'darkgrey', 'bold')
call s:Highlight('oroshi_UIModeInsert', 'darkyellow', 'darkgrey', 'bold')
call s:Highlight('oroshi_UIModeVisual', 'darkblue', 'darkgrey', 'bold')
call s:Highlight('oroshi_UIModeSearch', 'orange', 'darkgrey', 'bold')
call s:Highlight('oroshi_UIModeCtrlP', 'calmred', 'darkgrey', 'bold')
call s:Highlight('oroshi_UIModeCtrlF', 'darkgreen', 'darkgrey', 'bold')
" }}}

" Borders {{{
call s:Link('LineNr', 'oroshi_TextSecondary')
call s:Link('SignColumn', 'oroshi_TextSecondary')
call s:Link('ColorColumn', 'oroshi_UIWarning')
call s:Link('VertSplit', 'oroshi_UI')
" }}}
" Tabs {{{
call s:Link('TabLine', 'oroshi_UI')
call s:Link('TabLineFill', 'oroshi_UI')
call s:Link('TabLineSel', 'oroshi_UIActive')
" }}}
" Syntastic gutter {{{
call s:Link('SyntasticWarningSign', 'oroshi_Warning')
call s:Link('SyntasticErrorSign', 'oroshi_Error')
" }}}
" GitGutter {{{
call s:Link('GitGutterAdd', 'oroshi_Success')
call s:Link('GitGutterChange', 'oroshi_Notice')
" }}}
" Status line {{{
call s:Link('StatusLine', 'oroshi_UI')
call s:Link('StatusLineNC', 'oroshi_UIFilled')
" }}}
" Quick fix window {{{
" Note: The Search highlight is used in the quickfix window for the current
" element. This method is called whenever the quickfix window got focus and
" change the Search coloring, and revert it when losing focus.
function! UpdateSearchColoring(...)
  " buftype is either empty or 'quickfix', and can be specifed as an argument
  let buftype = (a:0 == 1) ? a:1 : &buftype

  if buftype == 'quickfix'
    " Removing coloring in quickfix
    hi clear Search
    hi link Search NONE
  else
    " Reverting initial coloring
    call s:Link('Search', 'oroshi_Search')
  endif
endfunction

augroup quickfix_coloring
  au!
  au BufWinEnter quickfix call UpdateSearchColoring('quickfix')
  au WinEnter * call UpdateSearchColoring()
augroup END
" }}}

" Cursor {{{
call s:Link('CursorLine', 'oroshi_TextHighlight')
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

" Basic text {{{
call s:Link('Normal', 'oroshi_Text')
call s:Link('NonText', 'oroshi_TextTertiary')
call s:Link('SpecialKey', 'oroshi_Warning')
" Messages
call s:Link('WarningMsg', 'oroshi_Warning')
call s:Link('ErrorMsg', 'oroshi_Error')
" Spellchecking
call s:Link('SpellBad', 'oroshi_TextSpellingError')
call s:Link('SpellCap', 'oroshi_TextSpellingError')
" }}}
" Extended text {{{
" Code
call s:Highlight('oroshi_TextCode', 'calmblue')
" Emphasis
call s:Highlight('oroshi_TextEmphasisBold', 'grey', '', 'bold')
call s:Highlight('oroshi_TextEmphasisItalic', 'grey')
" List marker
call s:Highlight('oroshi_TextListMarker', 'white', '', 'bold')
" Headings
call s:Highlight('oroshi_TextHeadingOne', 'darkgreen', '', 'bold')
call s:Highlight('oroshi_TextHeadingTwo', 'darkgreen')
call s:Highlight('oroshi_TextHeadingThree', 'green', '', 'bold')
call s:Highlight('oroshi_TextHeadingFour', 'green')
call s:Highlight('oroshi_TextHeadingFive', 'calmgreen', '', 'bold')
call s:Highlight('oroshi_TextHeadingSix', 'calmgreen')
" Delimiter
call s:Highlight('oroshi_TextDelimiter', 'darkyellow')
" Link
call s:Highlight('oroshi_TextLink', 'calmred')
call s:Highlight('oroshi_TextUrl', 'calmorange')
" }}}
" Operators {{{
call s:Highlight('Operator', 'white')
call s:Highlight('oroshi_Chute', 'darkblue')
" }}}
" Comments {{{
call s:Highlight('Comment', 'grey')
call s:Highlight('Todo', 'red', 'black', 'bold')
call s:Highlight('SpecialComment', 'grey', '', 'bold')
" }}}

" Class {{{
call s:Highlight('Type', 'calmred')
" Classname when defining the class
call s:Highlight('oroshi_ClassName', 'darkorange')
" }}}
" Functions {{{
call s:Highlight('Function', 'green')
" }}}
" PreProc {{{
call s:Highlight('PreProc', 'yellow')
" Eval is evil
call s:Highlight('oroshi_Eval', 'yellow')
" }}}
" Logic blocks {{{
call s:Highlight('Statement', 'darkgreen')
" }}}

" Variables {{{
call s:Highlight('Identifier', 'calmgreen', '', 'none')
" Constant
call s:Highlight('Constant', 'darkorange')
" Self refering in a class (self, this)
call s:Highlight('oroshi_ClassSelf', 'darkorange', '', 'bold')
" }}}
" Strings {{{
call s:Highlight('String', 'calmblue')
" Characters with special meaning
call s:Highlight('SpecialChar', 'darkyellow')
call s:Link('Character', 'SpecialChar')
" }}}
" Numbers {{{
call s:Highlight('Number', 'calmblue', '', 'bold')
" }}}
" Symbols {{{
" :symbol (Python/Ruby like)
call s:Highlight('oroshi_Symbol', 'orange')
" }}}
" Boolean {{{
call s:Highlight('Boolean', 'calmorange')
" }}}
" Regexps {{{
call s:Highlight('oroshi_Regexp', 'darkblue')
call s:Highlight('oroshi_RegexpFlags', 'orange')
call s:Highlight('oroshi_RegexpDelimiter', 'calmyellow')
call s:Highlight('oroshi_RegexpPattern', 'darkblue')
call s:Highlight('oroshi_RegexpBrackets', 'darkorange')
call s:Highlight('oroshi_RegexpReplacement', 'white')
call s:Highlight('oroshi_RegexpSpecial', 'darkyellow')
" }}}

" Css {{{
" Tag name
call s:Highlight('cssTagName', 'darkgreen')
call s:Link('sassClass', 'cssTagName')
" Class name
call s:Highlight('cssClassName', 'green')
" Operators
call s:Link('cssSelectorOp', 'Operator')
call s:Link('cssMediaComma', 'Operator')
call s:Link('cssBraces', 'Operator')
" :pseudo-class
call s:Highlight('cssPseudoClass', 'darkorange')
call s:Link('cssPseudoClassId', 'cssPseudoClass')
" @media
call s:Highlight('cssMedia', 'yellow', '', 'bold')
call s:Highlight('cssMediaType', 'orange')
" !important
call s:Link('cssImportant', 'Todo')
" [attributes]
call s:Highlight('cssAttributeSelector', 'red')
" properties:
call s:Highlight('cssProp', 'calmred')
call s:Link('cssVendorPrefixProp', 'cssProp')
call s:Link('cssBoxProp', 'cssProp')
call s:Link('cssFontProp', 'cssProp')
call s:Link('cssTextProp', 'cssProp')
call s:Link('cssFontAttr', 'cssProp')
call s:Link('cssColorProp', 'cssProp')
call s:Link('cssRenderProp', 'cssProp')
call s:Link('cssGeneratedContentProp', 'cssProp')
" values;
call s:Highlight('cssValue', 'calmblue')
call s:Link('cssCommonAttr', 'cssValue')
call s:Link('cssRenderAttr', 'cssValue')
call s:Link('cssBoxAttr', 'cssValue')
call s:Link('cssTextAttr', 'cssValue')
call s:Link('cssFontAttr', 'cssValue')
" }}}
" Diff {{{
call s:Link('DiffRemoved', 'oroshi_DiffDelete')
call s:Link('DiffAdded', 'oroshi_DiffAdd')
call s:Link('DiffLine', 'oroshi_DiffLine')
call s:Link('DiffFile', 'oroshi_DiffHeader')
" }}}
" Gitcommit {{{
call s:Link('gitCommitHeader', 'oroshi_TextEmphasisBold')
call s:Link('gitcommitBranch', 'oroshi_DiffBranch')
call s:Link('gitcommitSelectedFile', 'oroshi_DiffModifiedFile')
call s:Link('gitcommitUntrackedFile', 'oroshi_DiffUntrackedFile')
call s:Highlight('gitcommitSelectedType', 'darkblue')
call s:Highlight('gitcommitSummary', 'white')
call s:Highlight('gitcommitOverflow', 'calmred', 'darkgrey')
" }}}
" Hgcommit {{{
call s:Link('hgcommitBranch', 'oroshi_DiffBranch')
call s:Link('hgcommitAdded', 'oroshi_DiffAdd')
call s:Link('hgcommitRemoved', 'oroshi_DiffDelete')
call s:Link('hgcommitChanged', 'oroshi_DiffChange')
call s:Link('hgcommitDiffFile', 'oroshi_DiffHeader')
call s:Link('hgcommitDiffOldFile', 'oroshi_DiffOldFile')
call s:Link('hgcommitDiffNewFile', 'oroshi_DiffNewFile')
call s:Link('hgcommitDiffLine', 'oroshi_DiffLine')
call s:Link('hgcommitDiffAdded', 'oroshi_DiffAdd')
call s:Link('hgcommitDiffRemoved', 'oroshi_DiffDelete')
call s:Link('hgcommitDiffChanged', 'oroshi_DiffChange')
" }}}
" Html {{{
" Disable styling of special tags
call s:Link('htmlItalic', 'Normal')
call s:Link('htmlLink', 'Normal')
call s:Link('htmlTitle', 'Normal')
" }}}
" Lighttpd {{{
call s:Link('lighttpdSpecial', 'Boolean')
" }}}
" Markdown {{{
" Code
call s:Link('MarkdownCode', 'oroshi_TextCode')
call s:Link('MarkdownCodeblock', 'oroshi_TextCode')
call s:Link('MarkdownCodeDelimiter', 'oroshi_TextCode')
" Emphasis
call s:Link('MarkdownBold', 'oroshi_TextEmphasisBold')
call s:Link('MarkdownItalic', 'oroshi_TextEmphasisItalic')
" List
call s:Link('MarkdownListMarker', 'oroshi_TextListMarker')
" Link
call s:Link('MarkdownLinkDelimiter', 'oroshi_TextLink')
call s:Link('MarkdownIdDeclaration', 'oroshi_TextLink')
call s:Link('MarkdownLinkText', 'oroshi_TextLink')
call s:Link('MarkdownLinkTextDelimiter', 'oroshi_TextLink')
call s:Link('MarkdownUrlTitle', 'oroshi_TextLink')
call s:Link('MarkdownUrlTitleDelimiter', 'oroshi_TextLink')
call s:Link('MarkdownUrl', 'oroshi_TextUrl')
" Headings
call s:Link('MarkdownH1', 'oroshi_TextHeadingOne')
call s:Link('MarkdownH2', 'oroshi_TextHeadingTwo')
call s:Link('MarkdownH3', 'oroshi_TextHeadingThree')
call s:Link('MarkdownH4', 'oroshi_TextHeadingFour')
call s:Link('MarkdownH5', 'oroshi_TextHeadingFive')
call s:Link('MarkdownHeadingDelimiter', 'oroshi_TextDelimiter')
call s:Link('MarkdownHeadingRule', 'oroshi_TextDelimiter')
" }}}
" PHP {{{
" Class
call s:Link('phpSpecial', 'Type')
" Include $ in variable highlighting
call s:Link('phpVarSelector', 'Identifier')
" }}}
" Ruby {{{
" |chute|
call s:Link('rubyBlockParameterList', 'oroshi_Chute')
" Class
call s:Link('rubyClass', 'Type')
call s:Link('rubyDefine', 'Type')
" Class name
call s:Link('rubyConstant', 'Constant')
" Function
call s:Link('rubyFunction', 'Function')
call s:Link('rubyAttribute', 'Function')
" eval
call s:Link('rubyEval', 'oroshi_Eval')
" Logic blocks
call s:Link('rubyControl', 'Statement')
" self
call s:Link('rubyPseudoVariable', 'oroshi_ClassSelf')
" String
call s:Link('rubyString', 'String')
call s:Link('rubyStringDelimiter', 'String')
call s:Link('rubyInterpolation', 'SpecialChar')
call s:Link('rubyInterpolationDelimiter', 'SpecialChar')
call s:Link('rubyStringEscape', 'SpecialChar')
" :symbol
call s:Link('rubySymbol', 'oroshi_Symbol')
" Regexp
call s:Link('rubyRegexp', 'oroshi_Regexp')
call s:Link('rubyRegexpDelimiter', 'oroshi_RegexpDelimiter')
call s:Link('rubyRegexpSpecial', 'oroshi_RegexpSpecial')
" Predefined constants
call s:Link('rubyPredefinedConstant', 'Constant')
" }}}
" Vim {{{
" Option name
call s:Highlight('vimOption', 'orange')
call s:Link('vimFTOption', 'vimOption')
call s:Link('vimHiClear', 'vimOption')
call s:Link('vimSynType', 'vimOption')
call s:Link('vimAutoEvent', 'vimOption')
call s:Link('vimNormCmds', 'vimOption')
call s:Link('vimMapLhs', 'vimOption')
" Option value
call s:Highlight('vimSet', 'blue')
call s:Link('vimSetEqual', 'vimSet')
call s:Link('vimMapRhs', 'vimSet')
" Option separator
call s:Link('vimSetSep', 'Normal')
" Variables
call s:Link('vimVar', 'Identifier')
call s:Link('vimIsCommand', 'Identifier')
" Functions
call s:Link('vimFunc', 'Function')
call s:Link('vimUserFunc', 'Function')
call s:Link('vimFunction', 'Function')
call s:Link('vimFuncSID', 'Function')
" <SpecialKeys> like <F12>
call s:Link('vimNotation', 'SpecialKey')
call s:Link('vimMapMod', 'SpecialKey')
call s:Link('vimBracket', 'SpecialKey')
call s:Link('vimMapModkey', 'SpecialKey')
" Regexp
call s:Link('vimAddress', 'vimOption')
call s:Link('vimSubst1', 'vimOption')
call s:Link('vimSubstFlags', 'oroshi_RegexpFlags')
call s:Link('vimSubstPat', 'oroshi_RegexpPattern')
call s:Link('vimSubstDelim', 'oroshi_RegexpDelimiter')
" Comment title, eg. Author : Foobar
call s:Highlight('vimCommentTitle', 'grey', '', 'bold')
" }}}
" Vim Diff {{{
call s:Link('DiffAdd', 'oroshi_DiffAddBg')
call s:Link('DiffDelete', 'oroshi_DiffDeleteBg')
call s:Link('DiffChange', 'oroshi_DiffChangeBg')
call s:Link('DiffText', 'oroshi_DiffChange')
" }}}
" Vim Help {{{
call s:Link('helpSectionDelim', 'vimCommentTitle')
call s:Link('helpSpecial', 'vimNotation')
call s:Link('helpOption', 'vimOption')
call s:Link('helpHypertextJump', 'oroshi_TextLink')
call s:Link('helpExample', 'vimString')
call s:Link('helpHeader', 'vimComment')
call s:Link('helpNotVi', 'WarningMsg')
" }}}
" Xml {{{
" Tags
call s:Link('xmlTagName', 'Statement')
call s:Link('xmlEndTag', 'Statement')
" }}}
" Zsh {{{
" Variables
call s:Link('zshDeref', 'Identifier')
call s:Link('zshShortDeref', 'Identifier')
call s:Link('zshSubst', 'Identifier')
" Quotes surrounding strings
call s:Link('shQuote', 'String')
call s:Link('shDoubleQuote', 'String')
" }}}
"
" Ctrl-F {{{
" Found file
call s:Highlight('qfFilename', 'green')
" }}}
" RainbowParentheses {{{
let g:rbpt_colorpairs = [
    \ [get(s:palette, "darkred"),250],
    \ [get(s:palette, "red"),250],
    \ [get(s:palette, "calmred"),250],
    \ [get(s:palette, "darkpink"),250],
    \ [get(s:palette, "pink"),250],
    \ [get(s:palette, "calmpink"),250],
    \ [get(s:palette, "darkpurple"),250],
    \ [get(s:palette, "purple"),250],
    \ [get(s:palette, "calmpurple"),250], 
    \ [get(s:palette, "darkblue"),250],
    \ [get(s:palette, "blue"),250],
    \ [get(s:palette, "calmblue"),250],
    \ [get(s:palette, "darkorange"),250],
    \ [get(s:palette, "orange"),250],
    \ [get(s:palette, "calmorange"),250],
    \ [get(s:palette, "darkgreen"),250],
    \ [get(s:palette, "green"),250],
    \ [get(s:palette, "calmgreen"),250],
    \ [get(s:palette, "lightgrey"),250],
    \ ]
" }}}
