" Name:         Oroshi
" Maintainer:   Tim Carry <tim@pixelastic.com>
" "C'est parce qu'il y a 6 matières, c'est ca ?"
" "J'ai un coude chaud."

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
  if foreground ==# '' && background ==# '' && decoration ==# ''
    return
  endif

  " We build the highlight string
  let result = 'hi! '.name
  if foreground !=# ''
    let result .= ' guifg='.get(s:color, foreground)
  endif
  if background !=# ''
    let result .= ' guibg='.get(s:color, background)
  endif
  if decoration !=# ''
    let result .= ' gui='.decoration
  endif

  execute result
endfunction
" }}}

" Defining the palette from the ENV variables {{{
let s:color = {}
" Build the s:color palette
for key in split($COLORS_INDEX, ' ')
   execute 'let s:color[key]=$COLOR_' . key . '_HEXA'
endfor
" }}}

" Text {{{
call s:Highlight('Boolean', 'ALIAS_BOOLEAN', '', 'bold')
call s:Highlight('Comment', 'ALIAS_COMMENT')
call s:Highlight('Constant', 'ALIAS_CONSTANT', '', 'bold')
call s:Highlight('Conditional', 'ALIAS_STATEMENT')
call s:Highlight('Repeat', 'ALIAS_STATEMENT')
call s:Highlight('Delimiter', 'ALIAS_PUNCTUATION')
call s:Highlight('Error', 'ALIAS_ERROR', 'BLACK', 'bold')
call s:Highlight('Function', 'ALIAS_FUNCTION')
call s:Highlight('Identifier', 'ALIAS_VARIABLE')
call s:Highlight('Keyword', 'ALIAS_KEYWORD')
call s:Highlight('Noise', 'ALIAS_NOISE')
call s:Highlight('Normal', 'ALIAS_TEXT')
call s:Highlight('Number', 'ALIAS_NUMBER', '', 'bold')
call s:Highlight('Operator', 'ALIAS_PUNCTUATION')
call s:Highlight('PreProc', 'ALIAS_HEADER')
call s:Highlight('Title', 'ALIAS_HEADER')
call s:Highlight('Special', 'ALIAS_SPECIAL_CHAR')
call s:Highlight('Statement', 'ALIAS_STATEMENT')
call s:Highlight('StorageClass', 'ALIAS_VARIABLE_TYPE')
call s:Highlight('Type', 'ALIAS_VARIABLE_TYPE')
call s:Highlight('StringDelimiter', 'ALIAS_STRING')
call s:Highlight('String', 'ALIAS_STRING')

" Hidden characters (F8) {{{
" Line endings and horizontal scroll markers
call s:Highlight('NonText', 'GRAY_8')
" Tabs and whitespaces
call s:Highlight('Whitespace', 'YELLOW')
" }}}
"
" }}}
" UI {{{
" Borders {{{
call s:Highlight('ColorColumn', 'YELLOW', 'GRAY_9')
call s:Highlight('LineNr', 'GRAY')
call s:Highlight('SignColumn', 'NONE', 'terminal')
call s:Highlight('VertSplit', 'GRAY_9', 'GRAY_9', 'bold')
" }}}
" Tabs {{{
call s:Highlight('TabLineFill', 'GRAY_8', 'GRAY_9', 'none')
call s:Highlight('TabLineSel', 'YELLOW', 'GRAY_8', 'bold')
call s:Highlight('TabLine', 'GRAY_4', 'GRAY_9', 'none')
" }}}
" Cursor {{{
call s:Highlight('CursorLineNr', 'YELLOW', '', 'bold')
call s:Highlight('CursorLine', '', 'GRAY_9', 'none')

" Normal mode
call s:Highlight('CursorNormal', '', 'RED', 'none')
let s:guicursor = 'n:block-CursorNormal'

" Waiting for an operator
call s:Highlight('CursorOperatorPending', '', 'RED_5', 'none')
let s:guicursor .= ',o:block-CursorOperatorPending'

" Insert mode
call s:Highlight('CursorInsert', '', 'YELLOW', 'none')
let s:guicursor .= ',i:block-CursorInsert'

" Visual mode
call s:Highlight('CursorVisual', '', 'BLUE', 'none')
let s:guicursor .= ',v:block-CursorVisual'

" Command mode
call s:Highlight('CursorCommand', '', 'TEAL', 'none')
let s:guicursor .= ',c:block-CursorCommand'
" When editing the current command
call s:Highlight('CursorCommandInsert', '', 'TEAL', 'none')
let s:guicursor .= ',ci:block-CursorCommandInsert'

" Not sure what those do, so let's color them cyan and see when that happens
call s:Highlight('CursorReplace', '', 'CYAN', 'none')
let s:guicursor .= ',r:block-CursorReplace'
call s:Highlight('CursorCommandReplace', '', 'CYAN', 'none')
let s:guicursor .= ',cr:block-CursorCommandReplace'
call s:Highlight('CursorInsertShowmatch', '', 'CYAN', 'none')
let s:guicursor .= ',sm:block-CursorInsertShowmatch'

execute 'set guicursor='.s:guicursor
" }}}
" Folds {{{
call s:Highlight('Folded', 'ALIAS_TEXT', 'GRAY_8')
" }}}
" Visual selection {{{
call s:Highlight('Visual', 'WHITE', 'BLUE', 'bold')
" }}}
" Search {{{
call s:Highlight('IncSearch', 'BLACK', 'YELLOW', 'none')
call s:Highlight('Search', 'BLACK', 'YELLOW', 'bold')
" }}}
" Syntastic gutter {{{
call s:Highlight('SyntasticErrorSign', 'RED')
call s:Highlight('SyntasticStyleErrorSign', 'RED')
call s:Highlight('SyntasticStyleWarningSign', 'YELLOW')
call s:Highlight('SyntasticWarningSign', 'YELLOW')
" }}}
" Coc Gutter {{{
call s:Highlight('CocErrorSign', 'RED')
call s:Highlight('CocWarningSign', 'YELLOW')
call s:Highlight('CocInfoSign', 'BLUE')
" }}}
" GitGutter {{{
call s:Highlight('GitGutterAdd', 'GREEN')
call s:Highlight('GitGutterChange', 'purple')
" }}}
" Status line {{{
call s:Highlight('StatusLineFileEncodingError', 'RED', 'GRAY_8')
call s:Highlight('StatusLineFileFormatError', 'RED', 'GRAY_8')
call s:Highlight('StatusLineGitClean', 'GREEN', 'GRAY_8')
call s:Highlight('StatusLineGitDirty', 'RED', 'GRAY_8', 'bold')
call s:Highlight('StatusLineGitStaged', 'purple4', 'GRAY_8')
call s:Highlight('StatusLineModeCtrlPSeparator', 'RED5', 'GRAY_8')
call s:Highlight('StatusLineModeCtrlP', 'BLACK', 'RED_5', 'bold')
call s:Highlight('StatusLineModeInsertSeparator', 'YELLOW', 'GRAY_8')
call s:Highlight('StatusLineModeInsert', 'BLACK', 'YELLOW', 'bold')
call s:Highlight('StatusLineModeNormalSeparator', 'BLACK', 'GRAY_8')
call s:Highlight('StatusLineModeNormal', 'white', 'BLACK')
call s:Highlight('StatusLineModeSearchSeparator', 'GREEN', 'GRAY_8')
call s:Highlight('StatusLineModeSearch', 'BLACK', 'GREEN', 'bold')
call s:Highlight('StatusLineModeCommandSeparator', 'TEAL', 'GRAY_8')
call s:Highlight('StatusLineModeCommand', 'BLACK', 'TEAL', 'bold')
call s:Highlight('StatusLineModeUnknownSeparator', 'RED', 'white')
call s:Highlight('StatusLineModeUnknown', 'white', 'RED')
call s:Highlight('StatusLineModeVisualSeparator', 'BLUE', 'GRAY_8')
call s:Highlight('StatusLineModeVisual', 'white', 'BLUE', 'bold')
call s:Highlight('StatusLineNC', '', 'GRAY_8', 'none')
call s:Highlight('StatusLinePathModified', 'VIOLET_4', 'GRAY_8')
call s:Highlight('StatusLinePathReadonly', 'RED', 'GRAY_8')
call s:Highlight('StatusLinePath', 'GREEN', 'GRAY_8', 'bold')
call s:Highlight('StatusLineRight', 'GRAY_4', 'GRAY_8', 'none')
call s:Highlight('StatusLineError', 'RED', 'GRAY_8')
call s:Highlight('StatusLineWarning', 'YELLOW', 'GRAY_8')
call s:Highlight('StatusLine', 'GRAY_4', 'GRAY_8', 'none')
" Coloring the StatusLine filetypes
for key in split($FILETYPES_INDEX, ' ')
  execute 'let filetypeColor=$FILETYPE_' . key . '_COLOR_NAME'
  call s:Highlight('Filetype_' . key, filetypeColor, 'GRAY_8')
endfor
" Coloring the StatusLine projects
for key in split($PROJECTS_INDEX, ' ')
  execute 'let projectForeground=$PROJECT_' . key . '_FOREGROUND_NAME'
  execute 'let projectBackground=$PROJECT_' . key . '_BACKGROUND_NAME'
  call s:Highlight('ProjectPre_' . key, 'GRAY_8', projectBackground)
  call s:Highlight('Project_' . key, projectForeground, projectBackground)
  call s:Highlight('ProjectPost_' . key, projectBackground, 'GRAY_8')
endfor
" }}}
" Completion {{{
" Dropdown default colors
call s:Highlight('Pmenu', 'GRAY_4', 'GREEN_8')
" [F] and [A] on right hand side
call s:Highlight('CocPumShortcut', 'GRAY_4', '')
" Selected item (used either by Coc or default menu)
call s:Highlight('PmenuSel', 'BLACK', 'YELLOW', 'bold')
call s:Highlight('CocMenuSel', 'BLACK', 'YELLOW', 'bold')
" Scrollbar
call s:Highlight('PmenuSbar', '', 'GREEN_9')
" Thumb of the scrollbar
call s:Highlight('PmenuThumb', '', 'GRAY_4')
" Matching results in the dropdown
call s:Highlight('CocPumSearch', 'YELLOW', 'GREEN_9', 'underline')
" Suggested text on the line
call s:Highlight('CocPumVirtualText', 'GRAY_6', '')
" Below are unknown groups, so we put them cyan to see if they appear
call s:Highlight('CocPumMenu', 'CYAN', 'CYAN')
call s:Highlight('CocPumDeprecated', 'CYAN', 'CYAN')
" }}}
" Matching parenthesis {{{
call s:Highlight('MatchParen', 'white', 'TEAL_9')
" }}}
" Messages {{{
call s:Highlight('ErrorMsg', 'RED', 'none', 'bold')
call s:Highlight('WarningMsg', 'YELLOW_8')
" }}}
" Spell Checking / Errors {{{
call s:Highlight('SpellBad', 'RED', 'BLACK', 'bold,underline')
call s:Highlight('SpellCap', 'RED', 'BLACK', 'bold,underline')
" }}}

" AutoIt {{{
call s:Highlight('autoitString', 'BLUE')
call s:Highlight('autoitQuote', 'BLUE')
call s:Highlight('autoitNumber', 'BLUE', '', 'bold')
call s:Highlight('autoitParen', 'TEAL_7')
call s:Highlight('autoitKeyword', 'GREEN_7')
call s:Highlight('autoitVariable', 'PURPLE_4')
call s:Highlight('autoitVarSelector', 'PURPLE_4', '', 'bold')
call s:Highlight('autoitFunction', 'YELLOW')
call s:Highlight('autoitBuiltin', 'YELLOW', '', 'bold')
" }}}
" CSS {{{
call s:Highlight('cssAttr', 'VIOLET')
call s:Highlight('cssBraces', 'TEAL_7')
call s:Highlight('cssColor', 'VIOLET')
call s:Highlight('cssCommonAttr', 'VIOLET')
call s:Highlight('cssNoise', 'NEUTRAL')
call s:Highlight('cssProp', 'AMBER')
call s:Highlight('cssUnitDecorators', 'NEUTRAL_LIGHT')
call s:Highlight('cssPseudoClassId', 'CYAN')
call s:Highlight('cssPseudoClass', 'CYAN')
call s:Highlight('cssTagName', 'GREEN_8')
call s:Highlight('scssImport', 'YELLOW', '', 'bold')
call s:Highlight('scssVariable', 'YELLOW')
call s:Highlight('scssProperty', 'YELLOW')
call s:Highlight('scssSelectorChar', 'GREEN')
call s:Highlight('scssSelectorName', 'GREEN')
call s:Highlight('scssSemicolon', 'TEAL_7')
" }}}
" Git {{{
" call s:Highlight('diffAdded', 'GREEN_5')
" call s:Highlight('diffFile', 'YELLOW_6')
" call s:Highlight('diffIndexLine', 'YELLOW_7')
" call s:Highlight('diffOldFile', 'YELLOW_8')
" call s:Highlight('diffNewFile', 'YELLOW_8')
" call s:Highlight('diffLine', 'BLACK')
" call s:Highlight('diffRemoved', 'RED_7')
" call s:Highlight('diffSubname', 'GRAY_6')
" call s:Highlight('gitDiff', 'GRAY')
" call s:Highlight('gitcommitBlank', 'RED')
" call s:Highlight('gitcommitBranch', 'ORANGE')
" call s:Highlight('gitcommitDiff', 'GRAY')
" call s:Highlight('gitcommitHeader', 'GRAY')
" call s:Highlight('gitcommitOverflow', 'white', 'RED')
" call s:Highlight('gitcommitSelectedFile', 'GREEN')
" call s:Highlight('gitcommitSummary', 'white')
" call s:Highlight('gitcommitUntrackedFile', 'GRAY')
call s:Highlight('gitconfigSection', 'ALIAS_HEADER')
" call s:Highlight('gitconfigAssignment', 'BLUE')
" call s:Highlight('gitconfigVariable', 'PURPLE')
" }}}
" HTML {{{
call s:Highlight('htmlArg', 'ALIAS_VARIABLE_DEFINITION')
call s:Highlight('htmlBold', 'NEUTRAL_LIGHT', '', 'bold')
call s:Highlight('htmlEndTag', 'ALIAS_PUNCTUATION')
call s:Highlight('htmlItalic', 'NEUTRAL_LIGHT')
call s:Highlight('htmlLink', 'ALIAS_TEXT')
call s:Highlight('htmlSpecialChar', 'ALIAS_INTERPOLATION_VARIABLE')
call s:Highlight('htmlSpecialTagName', 'ALIAS_KEYWORD')
call s:Highlight('htmlTagName', 'ALIAS_KEYWORD')
call s:Highlight('htmlTag', 'ALIAS_PUNCTUATION')
call s:Highlight('htmlTitle', 'ALIAS_TEXT')
call s:Highlight('htmlh1', 'ALIAS_TEXT')
call s:Highlight('htmlh2', 'ALIAS_TEXT')
call s:Highlight('htmlh3', 'ALIAS_TEXT')
call s:Highlight('htmlh4', 'ALIAS_TEXT')
call s:Highlight('htmlh5', 'ALIAS_TEXT')
call s:Highlight('htmlh6', 'ALIAS_TEXT')
" }}}
" JavaScript / TypeScript {{{
call s:Highlight('jsVariableDef', 'ALIAS_VARIABLE')
call s:Highlight('jsTaggedTemplate', 'ALIAS_FUNCTION')
call s:Highlight('jsArrowFunction', 'ALIAS_PUNCTUATION')
call s:Highlight('jsTemplateBraces', 'ALIAS_INTERPOLATION_WRAPPER')
call s:Highlight('jsTemplateExpression', 'ALIAS_INTERPOLATION_VARIABLE')
call s:Highlight('jsGlobalNodeObjects', 'ALIAS_FUNCTION', '', 'bold')
" }}}
" JSONC {{{
call s:Highlight('jsoncKeywordMatch', 'BLUE')
augroup oroshi_jsonc
  autocmd!
  " The "Normal" highlight group is used for commas
  autocmd FileType jsonc call s:Highlight('Normal', 'TEAL_7')
augroup END
" }}}
" Markdown {{{
call s:Highlight('markdownCodeDelimiter', 'ALIAS_STRING')
call s:Highlight('markdownCode', 'ALIAS_STRING')
call s:Highlight('markdownHeadingDelimiter', 'ALIAS_HEADER')
call s:Highlight('markdownH1', 'ALIAS_HEADER', '', 'bold')
call s:Highlight('markdownH2', 'ALIAS_HEADER')
call s:Highlight('markdownH3', 'ALIAS_HEADER')
call s:Highlight('markdownH4', 'ALIAS_HEADER')
call s:Highlight('markdownH5', 'ALIAS_HEADER')
call s:Highlight('markdownH6', 'ALIAS_HEADER')
call s:Highlight('markdownListMarker', 'ALIAS_PUNCTUATION')
call s:Highlight('markdownLinkDelimiter', 'ALIAS_PUNCTUATION')
call s:Highlight('markdownLinkTextDelimiter', 'ALIAS_PUNCTUATION')
call s:Highlight('markdownLinkText', 'ALIAS_KEYWORD', '', 'underline')
call s:Highlight('markdownRule', 'ALIAS_PUNCTUATION')
call s:Highlight('markdownUrl', 'ALIAS_LINK')
" }}}
" Pug {{{
call s:Highlight('pugAngular2', 'BLUE_4', '', 'italic,bold')
call s:Highlight('pugAttributes', 'RED_5')
call s:Highlight('pugClassChar', 'TEAL_7')
call s:Highlight('pugJavascriptChar', 'TEAL_7')
call s:Highlight('pugJavascriptOutputChar', 'TEAL_7')
call s:Highlight('pugScriptLoopKeywords', 'YELLOW')
call s:Highlight('pugTag', 'YELLOW')
" }}}
" Ruby {{{
call s:Highlight('rubyDefine', 'ALIAS_VARIABLE_TYPE')
call s:Highlight('rubyConstant', 'ALIAS_VARIABLE_DEFINITION')
call s:Highlight('rubyClassName', 'ALIAS_VARIABLE_DEFINITION')
call s:Highlight('rubyStringDelimiter', 'ALIAS_STRING')
call s:Highlight('rubyArrayDelimiter', 'ALIAS_PUNCTUATION')
call s:Highlight('rubyBlockParameterList', 'ALIAS_VARIABLE')
call s:Highlight('rubyCurlyBlockDelimiter', 'ALIAS_PUNCTUATION')
call s:Highlight('rubyInterpolation', 'ALIAS_INTERPOLATION_VARIABLE')
call s:Highlight('rubyInterpolationDelimiter', 'ALIAS_INTERPOLATION_WRAPPER')
call s:Highlight('rubySymbol', 'ALIAS_SYMBOL')
" Following groups should be highlighted but aren't
call s:Highlight('rubyKeywordAsMethod', 'RED', 'CYAN')
" }}}
" Shell {{{
call s:Highlight('shDerefSimple', 'ALIAS_INTERPOLATION_VARIABLE')
call s:Highlight('shOption', 'ALIAS_FLAG')
call s:Highlight('shQuote', 'ALIAS_STRING')
call s:Highlight('shRANGE', 'ALIAS_PUNCTUATION')
call s:Highlight('shSetOption', 'ALIAS_FLAG')
call s:Highlight('shSet', 'ALIAS_FUNCTION')
call s:Highlight('shStatement', 'ALIAS_STATEMENT')
call s:Highlight('shSemicolon', 'ALIAS_PUNCTUATION')
" }}}
" Tmux {{{
call s:Highlight('tmuxBoolean', 'ORANGE', '', 'bold')
call s:Highlight('tmuxCommands', 'YELLOW')
call s:Highlight('tmuxFlags', 'ORANGE')
call s:Highlight('tmuxOptions', 'VIOLET')
call s:Highlight('tmuxKey', 'CYAN')
call s:Highlight('tmuxFormatString', 'YELLOW')
" }}}
" Vim {{{
call s:Highlight('vim9Comment', 'ALIAS_ERROR') " Comments using #
call s:Highlight('vimOption', 'ALIAS_VARIABLE')
call s:Highlight('vimBracket', 'ALIAS_SPECIAL_CHAR')
call s:Highlight('vimMapMod', 'ALIAS_SPECIAL_CHAR')
call s:Highlight('vimMapLhs', 'ALIAS_SPECIAL_CHAR')
call s:Highlight('vimMapRhs', 'ALIAS_FUNCTION')
call s:Highlight('vimComment', 'ALIAS_COMMENT')
call s:Highlight('vimLet', 'ALIAS_VARIABLE_TYPE')
call s:Highlight('vimSetEqual', 'ALIAS_KEYWORD')
call s:Highlight('vimSetSep', 'ALIAS_PUNCTUATION')
call s:Highlight('vimUserFunc', 'ALIAS_FUNCTION')
" }}}
" XML {{{
call s:Highlight('xmlTag', 'ALIAS_PUNCTUATION')
call s:Highlight('xmlEqual', 'ALIAS_PUNCTUATION')
call s:Highlight('xmlDocTypeDecl', 'ALIAS_PUNCTUATION')
call s:Highlight('xmlProcessingDelim', 'ALIAS_PUNCTUATION')
call s:Highlight('xmlTagName', 'ALIAS_KEYWORD')
call s:Highlight('xmlAttrib', 'ALIAS_VARIABLE')
" }}}
" Yaml {{{
call s:Highlight('yamlAlias', 'YELLOW_6')
call s:Highlight('yamlBlockCollectionItemStart', 'TEAL_7')
call s:Highlight('yamlFlowString', 'BLUE')
call s:Highlight('yamlKeyValueDelimiter', 'TEAL_7')
call s:Highlight('yamlPlainScalar', 'BLUE')
" }}}
" Zsh {{{
call s:Highlight('shStatement', 'ALIAS_FUNCTION')
call s:Highlight('zshCommands', 'ALIAS_FUNCTION')
call s:Highlight('zshDereferencing', 'ALIAS_VARIABLE')
call s:Highlight('zshKSHFunction', 'ALIAS_VARIABLE_DEFINITION')
call s:Highlight('zshKeyword', 'ALIAS_VARIABLE_TYPE')
call s:Highlight('zshSubst', 'ALIAS_INTERPOLATION_VARIABLE')
call s:Highlight('zshSubstDelim', 'ALIAS_INTERPOLATION_WRAPPER')
call s:Highlight('zshSwitches', 'ALIAS_FLAG')
call s:Highlight('zshTypes', 'ALIAS_VARIABLE_TYPE')
call s:Highlight('zshVariableDef', 'ALIAS_VARIABLE_DEFINITION')
call s:Highlight('zshVariable', 'ALIAS_VARIABLE_DEFINITION')
" }}}
