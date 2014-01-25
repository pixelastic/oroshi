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
" Highlighting function {{{
" args : group, foreground, background, cterm
function! s:HL(group,fg,...)
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
" args : group, link1, link2, link3, ...
function! s:Link(group,...)
	" Adding the link between first arg and any subsequent arg in turn
	for link in a:000
		execute 'hi! def link '.link.' '.a:group
	endfor
endfunction
" }}}

" UI Elements {{{
" Borders
call s:HL('LineNr', 'grey', 'black')
call s:HL('ColorColumn', 'white', 'darkgrey')
call s:HL('VertSplit', 'darkgrey', 'darkgrey')
" Tabs
call s:HL('TabLine', 'lightgrey', 'darkgrey', 'none')
call s:HL('TabLineFill', 'white', 'darkgrey', 'none')
call s:HL('TabLineSel', 'white', 'black', 'bold')
" Signs
call s:Link('LineNr', 'SignColumn')
call s:HL('SyntasticWarningSign', 'yellow', 'yellow')
call s:HL('SyntasticErrorSign', 'red', 'red')
" }}}
" Completion menu {{{
call s:HL('Pmenu', 'lightgrey', 'darkgrey')
call s:HL('PmenuSel', 'black', 'calmorange', 'bold')
call s:HL('PmenuSbar', 'darkgrey', 'darkgrey')
" }}}
" Status line {{{
call s:HL('StatusLine', 'lightgrey', 'darkgrey', 'bold')
call s:HL('StatusLineNC', 'grey', 'darkgrey', 'none')
" Mode arrow highlight
call s:HL('oroshi_StatusLineModeNormal', 'white', 'black', 'bold')
call s:HL('oroshi_StatusLineModeInsert', 'black', 'darkyellow', 'bold')
call s:HL('oroshi_StatusLineModeVisual', 'lightgrey', 'darkblue', 'bold')
call s:HL('oroshi_StatusLineModeSearch', 'black', 'orange', 'bold')
call s:HL('oroshi_StatusLineModeCtrlP', 'black', 'calmred', 'bold')
call s:HL('oroshi_StatusLineModeCtrlF', 'black', 'darkgreen', 'bold')

call s:HL('oroshi_StatusLineModeNormalArrow', 'black', 'darkgrey')
call s:HL('oroshi_StatusLineModeInsertArrow', 'darkyellow', 'darkgrey')
call s:HL('oroshi_StatusLineModeVisualArrow', 'darkblue', 'darkgrey')
call s:HL('oroshi_StatusLineModeSearchArrow', 'orange', 'darkgrey')
call s:HL('oroshi_StatusLineModeCtrlPArrow', 'calmred', 'darkgrey')
call s:HL('oroshi_StatusLineModeCtrlFArrow', 'darkgreen', 'darkgrey')
" File name coloring
call s:HL('oroshi_StatusLineReadOnly', 'red', 'darkgrey', 'bold')
call s:HL('oroshi_StatusLineModified', 'calmpurple', 'darkgrey', 'bold')
call s:HL('oroshi_StatusLineSaved', 'darkgreen', 'darkgrey')
" Git status coloring
call s:HL('oroshi_StatusLineGitDirty', 'red', 'darkgrey', 'bold')
call s:HL('oroshi_StatusLineGitStaged', 'calmpurple', 'darkgrey', 'bold')
call s:HL('oroshi_StatusLineGitClean', 'darkgreen', 'darkgrey')
" Warning/Errors coloring
call s:HL('oroshi_StatusLineSyntastic', 'calmred', 'darkgrey', 'bold')
" Arval testing
call s:HL('oroshi_TestPassSuccess', 'darkgreen', 'darkgrey', 'bold')
call s:HL('oroshi_TestPassFailure', 'red', 'darkgrey', 'bold')
" Wrong options
call s:HL('oroshi_StatusLineBadLineEnding', 'red', 'darkgrey', 'bold')
call s:HL('oroshi_StatusLineBadEncoding', 'red', 'darkgrey', 'bold')
" }}}
" Cursor {{{
call s:HL('CursorLine', 'none', 'almostblack', 'none')
call s:HL('CursorLineNr', 'white', 'almostblack', 'none')
if &term =~ "xterm"
	" Cursor in insert mode
	let &t_SI = "\<Esc>]12;#AF8700\x7"
	" Cursor in normal mode
	let &t_EI = "\<Esc>]12;#D70000\x7"
endif
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
		call s:Link('oroshi_Search', 'Search')
	endif
endfunction

augroup quickfix_coloring
	au!
	au BufWinEnter quickfix call UpdateSearchColoring('quickfix')
	au WinEnter * call UpdateSearchColoring()
augroup END
" }}}
" Vim utils {{{
" Visual selection
call s:HL('Visual', 'lightgrey', 'darkblue', 'bold')
" Search
call s:HL('IncSearch', 'black', 'orange', 'bold')
call s:HL('oroshi_Search', 'black', 'calmorange', 'bold')
call s:Link('oroshi_Search', 'Search')
" Folded text
call s:HL('Folded', 'lightgrey', 'darkgrey')
" Matching parenthesis
call s:HL('MatchParen', 'black', 'orange', 'bold')
" }}}

" Basic text {{{
call s:HL('Normal', 'white', 'black')
" Text markers
call s:HL('NonText', 'darkgrey')
" Unprintable chars
call s:HL('SpecialKey', 'darkyellow')
" Messages
call s:HL('WarningMsg', 'yellow', 'black', 'bold')
call s:HL('ErrorMsg', 'red', 'black')
" }}}
" Extended text {{{
" Code
call s:HL('oroshi_TextCode', 'calmblue')
" Emphasis
call s:HL('oroshi_TextEmphasisBold', 'grey', '', 'bold')
call s:HL('oroshi_TextEmphasisItalic', 'grey')
" List marker
call s:HL('oroshi_TextListMarker', 'white', '', 'bold')
" Headings
call s:HL('oroshi_TextHeadingOne', 'darkgreen', '', 'bold')
call s:HL('oroshi_TextHeadingTwo', 'darkgreen')
call s:HL('oroshi_TextHeadingThree', 'green', '', 'bold')
call s:HL('oroshi_TextHeadingFour', 'green')
call s:HL('oroshi_TextHeadingFive', 'calmgreen', '', 'bold')
call s:HL('oroshi_TextHeadingSix', 'calmgreen')
" Delimiter
call s:HL('oroshi_TextDelimiter', 'darkyellow')
" Link
call s:HL('oroshi_TextLink', 'calmred')
call s:HL('oroshi_TextUrl', 'calmorange')
" }}}
" Operators {{{
call s:HL('Operator', 'white')
" |x,y| Ruby style
call s:HL('oroshi_Chute', 'darkblue')
" }}}
" Comments {{{
call s:HL('Comment', 'grey')
call s:HL('Todo', 'red', 'black', 'bold')
call s:HL('SpecialComment', 'grey', '', 'bold')
" }}}
" Diff {{{
call s:HL('oroshi_DiffAdd', 'green')
call s:HL('oroshi_DiffAddBg', 'white', 'darkgreen', 'bold')
call s:HL('oroshi_DiffDelete', 'red')
call s:HL('oroshi_DiffDeleteBg', 'darkred', 'darkred')
call s:HL('oroshi_DiffChange', 'calmpurple')
call s:HL('oroshi_DiffChangeBg', 'white', 'darkgrey', 'none')
call s:HL('oroshi_DiffHeader', 'darkyellow', '', 'bold')
call s:HL('oroshi_DiffOldFile', 'darkred', '', 'bold')
call s:HL('oroshi_DiffNewFile', 'darkgreen', '', 'bold')
call s:HL('oroshi_DiffLine', 'calmpurple')
call s:HL('oroshi_DiffUntrackedFile', 'calmred')
call s:HL('oroshi_DiffModifiedFile', 'calmpurple')
call s:HL('oroshi_DiffDeletedFile', 'red')
call s:HL('oroshi_DiffBranch', 'orange')
" }}}

" Class {{{
call s:HL('Type', 'calmred')
" Classname when defining the class
call s:HL('oroshi_ClassName', 'darkorange')
" }}}
" Functions {{{
call s:HL('Function', 'green')
" }}}
" PreProc {{{
call s:HL('PreProc', 'yellow')
" Eval is evil
call s:HL('oroshi_Eval', 'yellow')
" }}}
" Logic blocks {{{
call s:HL('Statement', 'darkgreen')
" }}}

" Variables {{{
call s:HL('Identifier', 'calmgreen', '', 'none')
" Constant
call s:HL('Constant', 'darkorange')
" Self refering in a class (self, this)
call s:HL('oroshi_ClassSelf', 'darkorange', '', 'bold')
" }}}
" Strings {{{
call s:HL('String', 'calmblue')
" Characters with special meaning
call s:HL('SpecialChar', 'darkyellow')
call s:Link('SpecialChar', 'Character')
" }}}
" Numbers {{{
call s:HL('Number', 'calmblue', '', 'bold')
" }}}
" Symbols {{{
" :symbol (Python/Ruby like)
call s:HL('oroshi_Symbol', 'orange')
" }}}
" Boolean {{{
call s:HL('Boolean', 'calmorange')
" }}}
" Regexps {{{
call s:HL('oroshi_Regexp', 'darkblue')
call s:HL('oroshi_RegexpFlags', 'orange')
call s:HL('oroshi_RegexpDelimiter', 'calmyellow')
call s:HL('oroshi_RegexpPattern', 'darkblue')
call s:HL('oroshi_RegexpBrackets', 'darkorange')
call s:HL('oroshi_RegexpReplacement', 'white')
call s:HL('oroshi_RegexpSpecial', 'darkyellow')
" }}}

" Css {{{
" Tag name
call s:Link('Function', 'cssTagName', 'sassClass')
" Operators
call s:Link('Operator', 'cssSelectorOp', 'cssMediaComma', 'cssBraces')
" :pseudo-class
call s:HL('cssPseudoClass', 'darkorange')
call s:Link('cssPseudoClass', 'cssPseudoClassId')
" @media
call s:HL('cssMedia', 'yellow', '', 'bold')
call s:HL('cssMediaType', 'orange')
" !important
call s:Link('Todo', 'cssImportant')
" [attributes]
call s:HL('cssAttributeSelector', 'red')
" properties:
call s:HL('cssProp', 'calmred')
call s:Link('cssProp', 'cssVendorPrefixProp', 'cssBoxProp', 'cssFontProp', 'cssTextProp', 'cssFontAttr', 'cssColorProp', 'cssRenderProp', 'cssGeneratedContentProp')
" values;
call s:HL('cssValue', 'calmblue')
call s:Link('cssValue', 'cssCommonAttr', 'cssRenderAttr', 'cssBoxAttr', 'cssTextAttr', 'cssFontAttr')
" }}}
" Diff {{{
call s:Link('oroshi_DiffDelete', 'DiffRemoved')
call s:Link('oroshi_DiffAdd', 'DiffAdded')
call s:Link('oroshi_DiffLine', 'DiffLine')
call s:Link('oroshi_DiffHeader', 'DiffFile')
" }}}
" Gitcommit {{{
call s:Link('oroshi_TextEmphasisBold', 'gitCommitHeader')
call s:Link('oroshi_DiffBranch', 'gitcommitBranch')
call s:Link('oroshi_DiffModifiedFile', 'gitcommitSelectedFile')
call s:Link('oroshi_DiffUntrackedFile', 'gitcommitUntrackedFile')
call s:HL('gitcommitSelectedType', 'darkblue')
call s:HL('gitcommitSummary', 'white')
call s:HL('gitcommitOverflow', 'calmred', 'darkgrey')
" }}}
" Hgcommit {{{
call s:Link('oroshi_DiffBranch',  'hgcommitBranch')
call s:Link('oroshi_DiffAdd',     'hgcommitAdded')
call s:Link('oroshi_DiffDelete',  'hgcommitRemoved')
call s:Link('oroshi_DiffChange',  'hgcommitChanged')
call s:Link('oroshi_DiffHeader',  'hgcommitDiffFile')
call s:Link('oroshi_DiffOldFile', 'hgcommitDiffOldFile')
call s:Link('oroshi_DiffNewFile', 'hgcommitDiffNewFile')
call s:Link('oroshi_DiffLine',    'hgcommitDiffLine')
call s:Link('oroshi_DiffAdd',     'hgcommitDiffAdded')
call s:Link('oroshi_DiffDelete',  'hgcommitDiffRemoved')
call s:Link('oroshi_DiffChange',  'hgcommitDiffChanged')
" }}}
" Html {{{
" Disable styling of special tags
call s:Link('Normal', 'htmlItalic', 'htmlLink', 'htmlTitle')
" }}}
" Lighttpd {{{
call s:Link('Boolean', 'lighttpdSpecial')
" }}}
" Markdown {{{
" Code
call s:Link('oroshi_TextCode', 'MarkdownCode', 'MarkdownCodeblock', 'MarkdownCodeDelimiter')
" Emphasis
call s:Link('oroshi_TextEmphasisBold', 'MarkdownBold')
call s:Link('oroshi_TextEmphasisItalic', 'MarkdownItalic')
" List
call s:Link('oroshi_TextListMarker', 'MarkdownListMarker')
" Link
call s:Link('oroshi_TextLink', 'MarkdownLinkDelimiter', 'MarkdownIdDeclaration')
call s:Link('oroshi_TextLink', 'MarkdownLinkText', 'MarkdownLinkTextDelimiter')
call s:Link('oroshi_TextLink', 'MarkdownUrlTitle', 'MarkdownUrlTitleDelimiter')
call s:Link('oroshi_TextUrl', 'MarkdownUrl')
" Headings
call s:Link('oroshi_TextHeadingOne', 'MarkdownH1')
call s:Link('oroshi_TextHeadingTwo', 'MarkdownH2')
call s:Link('oroshi_TextHeadingThree', 'MarkdownH3')
call s:Link('oroshi_TextHeadingFour', 'MarkdownH4')
call s:Link('oroshi_TextHeadingFive', 'MarkdownH5')
call s:Link('oroshi_TextDelimiter', 'MarkdownHeadingDelimiter', 'MarkdownHeadingRule')
" }}}
" PHP {{{
" Class
call s:Link('Type', 'phpSpecial')
" Include $ in variable highlighting
call s:Link('Identifier', 'phpVarSelector')
" }}}
" Ruby {{{

" |chute|
call s:Link('oroshi_Chute', 'rubyBlockParameterList')

" Class
call s:Link('Type', 'rubyClass', 'rubyDefine')
" Class name
call s:Link('Constant', 'rubyConstant')
" Function
call s:Link('Function', 'rubyFunction', 'rubyAttribute')
" eval
call s:Link('oroshi_Eval', 'rubyEval')
" Logic blocks
call s:Link('Statement', 'rubyControl')

" self
call s:Link('oroshi_ClassSelf', 'rubyPseudoVariable')
" String
call s:Link('String', 'rubyString', 'rubyStringDelimiter')
call s:Link('SpecialChar', 'rubyInterpolation', 'rubyInterpolationDelimiter', 'rubyStringEscape')
" :symbol
call s:Link('oroshi_Symbol', 'rubySymbol')
" Regexp
call s:Link('oroshi_Regexp', 'rubyRegexp')
call s:Link('oroshi_RegexpDelimiter', 'rubyRegexpDelimiter')
call s:Link('oroshi_RegexpSpecial', 'rubyRegexpSpecial')
" Predefined constants
call s:Link('Constant', 'rubyPredefinedConstant')


" }}}
" Vim {{{
" Option name
call s:HL('vimOption', 'orange')
call s:Link('vimOption', 'vimFTOption', 'vimHiClear', 'vimSynType', 'vimAutoEvent')
call s:Link('vimOption', 'vimNormCmds', 'vimMapLhs')
" Option value
call s:HL('vimSet', 'blue')
call s:Link('vimSet', 'vimSetEqual', 'vimMapRhs')
" Option separator
call s:Link('Normal', 'vimSetSep')

" Variables
call s:Link('Identifier', 'vimVar', 'vimIsCommand')
" Functions
call s:Link('Function', 'vimFunc', 'vimUserFunc', 'vimFunction', 'vimFuncSID')

" <SpecialKeys> like <F12>
call s:Link('SpecialKey', 'vimNotation', 'vimMapMod', 'vimBracket', 'vimMapModkey')

" Regexp
call s:Link('vimOption', 'vimAddress', 'vimSubst1')
call s:Link('oroshi_RegexpFlags', 'vimSubstFlags')
call s:Link('oroshi_RegexpPattern', 'vimSubstPat')
call s:Link('oroshi_RegexpDelimiter', 'vimSubstDelim')

" Comment title, eg. Author : Foobar
call s:HL('vimCommentTitle', 'grey', '', 'bold')

" }}}
" Vim Diff {{{
call s:Link('oroshi_DiffAddBg', 'DiffAdd')
call s:Link('oroshi_DiffDeleteBg', 'DiffDelete')
call s:Link('oroshi_DiffChangeBg', 'DiffChange')
call s:Link('oroshi_DiffChange', 'DiffText')
" }}}
" Vim Help {{{
call s:Link('vimCommentTitle', 'helpSectionDelim')
call s:Link('vimNotation', 'helpSpecial')
call s:Link('vimOption', 'helpOption')
call s:Link('oroshi_TextLink', 'helpHypertextJump')
call s:Link('vimString', 'helpExample')
call s:Link('vimComment', 'helpHeader')
call s:Link('WarningMsg', 'helpNotVi')
" }}}
" Zsh {{{
" Variables
call s:Link('Identifier', 'zshDeref', 'zshShortDeref', 'zshSubst')
" Quotes surrounding strings
call s:Link('String', 'shQuote', 'shDoubleQuote')
" }}}

" Ctrl-F {{{
" Found file
call s:HL('qfFilename', 'green')
" }}}
" Ctrl-P {{{
" Highlighting:~
"   * For the CtrlP buffer:
"     CtrlPNoEntries : the message when no match is found (Error)
"     CtrlPMatch     : the matched pattern (Identifier)
"     CtrlPLinePre   : the line prefix '>' in the match window
"     CtrlPPrtBase   : the prompt's base (Comment)
"     CtrlPPrtText   : the prompt's text (|hl-Normal|)
"     CtrlPPrtCursor : the prompt's cursor when moving over the text (Constant)
" 
"   * In extensions:
"     CtrlPTabExtra  : the part of each line that's not matched against (Comment)
"     CtrlPBufName   : the buffer name an entry belongs to (|hl-Directory|)
"     CtrlPTagKind   : the kind of the tag in buffer-tag mode (|hl-Title|)
"     CtrlPqfLineCol : the line and column numbers in quickfix mode (Comment)
"     CtrlPUndoT     : the elapsed time in undo mode (|hl-Directory|)
"     CtrlPUndoBr    : the square brackets [] in undo mode (Comment)
"     CtrlPUndoNr    : the undo number inside [] in undo mode (String)
"     CtrlPUndoSv    : the point where the file was saved (Comment)
"     CtrlPUndoPo    : the current position in the undo tree (|hl-Title|)
"     CtrlPBookmark  : the name of the bookmark (Identifier)
" 
" Statuslines:~
"   * Highlight groups:
"     CtrlPMode1 : 'prt' or 'win', also for 'regex' (Character)
"     CtrlPMode2 : 'file' or 'path', also for the local working dir (|hl-LineNr|)
"     CtrlPStats : the scanning status (Function)
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
