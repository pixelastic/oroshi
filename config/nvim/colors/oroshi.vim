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
call s:Highlight('Boolean', 'ALIAS_BOOLEAN')
call s:Highlight('Comment', 'ALIAS_COMMENT')
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
call s:Highlight('Statement', 'ALIAS_STATEMENT')
call s:Highlight('StorageClass', 'ALIAS_VARIABLE_TYPE')
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

" Error checking
" Note: We don't highlight Coc errors as they tend to put everything under the
" same color and make it hard to visually parse. We rely on the gutter symbol
" instead.
" call s:Highlight('CocWarningHighlight', 'YELLOW', '', 'bold,underline')
" call s:Highlight('CocInfoHighlight', '', '', 'none')
" call s:Highlight('CocFloating', 'GRAY5', 'GRAY9')
" call s:Highlight('CocWarningFloat', 'YELLOW', 'GRAY9', 'bold')
" call s:Highlight('CocErrorFloat', 'RED', 'GRAY9', 'bold')
" call s:Highlight('CocErrorHighlight', '', '', 'bold')

" call s:Highlight('CocBold', 'CYAN', 'white')
" call s:Highlight('CocCodeLens', 'CYAN', 'white')
" call s:Highlight('CocCursorRange', 'CYAN', 'white')
" call s:Highlight('CocErrorHighlight', 'CYAN', 'white')
" call s:Highlight('CocHighlightRead', 'CYAN', 'white')
" call s:Highlight('CocHighlightText', 'CYAN', 'white')
" call s:Highlight('CocHighlightWrite', 'CYAN', 'white')
" call s:Highlight('CocHintFloat', 'CYAN', 'white')
" call s:Highlight('CocHintHighlight', 'CYAN', 'white')
" call s:Highlight('CocHintSign', 'CYAN', 'white')
" call s:Highlight('CocHoverRange', 'CYAN', 'white')
" call s:Highlight('CocInfoFloat', 'CYAN', 'white')
" call s:Highlight('CocInfoHighlight', 'CYAN', 'white')
" call s:Highlight('CocInfoSign', 'CYAN', 'white')
" call s:Highlight('CocItalic', 'CYAN', 'white')
" call s:Highlight('CocListMode', 'CYAN', 'white')
" call s:Highlight('CocListPath', 'CYAN', 'white')
" call s:Highlight('CocMarkdownCode', 'CYAN', 'white')
" call s:Highlight('CocMarkdownHeader', 'CYAN', 'white')
" call s:Highlight('CocMarkdownLink', 'CYAN', 'white')
" call s:Highlight('CocMenuSel', 'CYAN', 'white')
" call s:Highlight('CocSelectedText', 'CYAN', 'white')
" call s:Highlight('CocUnderline', 'CYAN', 'white')
" call s:Highlight('CocWarningHighlight', 'CYAN', 'white')
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
call s:Highlight('diffAdded', 'GREEN_5')
call s:Highlight('diffFile', 'YELLOW_6')
call s:Highlight('diffIndexLine', 'YELLOW_7')
call s:Highlight('diffOldFile', 'YELLOW_8')
call s:Highlight('diffNewFile', 'YELLOW_8')
call s:Highlight('diffLine', 'BLACK')
call s:Highlight('diffRemoved', 'RED_7')
call s:Highlight('diffSubname', 'GRAY_6')
call s:Highlight('gitDiff', 'GRAY')
call s:Highlight('gitcommitBlank', 'RED')
call s:Highlight('gitcommitBranch', 'ORANGE')
call s:Highlight('gitcommitDiff', 'GRAY')
call s:Highlight('gitcommitHeader', 'GRAY')
call s:Highlight('gitcommitOverflow', 'white', 'RED')
call s:Highlight('gitcommitSelectedFile', 'GREEN')
call s:Highlight('gitcommitSummary', 'white')
call s:Highlight('gitcommitUntrackedFile', 'GRAY')
call s:Highlight('gitconfigSection', 'YELLOW')
call s:Highlight('gitconfigAssignment', 'BLUE')
call s:Highlight('gitconfigVariable', 'PURPLE')
" }}}
" HTML {{{
call s:Highlight('htmlArg', 'ALIAS_VARIABLE_DEFINITION')
call s:Highlight('htmlEndTag', 'ALIAS_PUNCTUATION')
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
" call s:Highlight('jsArrowFunction', 'TEAL_7')
" call s:Highlight('jsAsyncKeyword', 'GREEN_7')
" call s:Highlight('jsBooleanFalse', 'RED_5', '', 'bold')
" call s:Highlight('jsBooleanTrue', 'GREEN', '', 'bold')
" call s:Highlight('jsDestructuringBlock', 'PURPLE_5')
" call s:Highlight('jsForAwait', 'GREEN_7')
" call s:Highlight('jsFuncArgs', 'VIOLET')
" call s:Highlight('jsFunction', 'RED_LIGHT')
" call s:Highlight('jsNoise', 'TEAL_7')
" call s:Highlight('jsNull', 'CYAN_5', '', 'bold')
" call s:Highlight('jsOperatorKeyword', 'GREEN_7', '', 'bold')
" call s:Highlight('jsParens', 'TEAL_7')
" call s:Highlight('jsRegexpBoundary', 'ORANGE')
" call s:Highlight('jsRegexpGroup', 'GREEN')
" call s:Highlight('jsRegexpOr', 'ORANGE')
" call s:Highlight('jsRegexpQuantifier', 'ORANGE')
" call s:Highlight('jsRegexpString', 'BLUE_4')
" call s:Highlight('jsReturn', 'GREEN', '', 'bold')
" call s:Highlight('jsStorageClass', 'GREEN_7')
" call s:Highlight('jsTemplateBraces', 'PURPLE_4')
" call s:Highlight('jsTemplateExpression', 'PURPLE_4')
" call s:Highlight('jsTemplateString', 'BLUE_6')
" call s:Highlight('jsThis', 'PURPLE_4')
" call s:Highlight('jsUndefined', 'ORANGE_6', '', 'bold')
" call s:Highlight('typescriptAccessibilityModifier', 'GREEN_7')
" call s:Highlight('typescriptAssign', 'TEAL_7')
" call s:Highlight('typescriptBOMWindowProp', 'YELLOW', '', 'bold')
" call s:Highlight('typescriptBraces', 'TEAL_7')
" call s:Highlight('typescriptClassKeyword', 'GREEN_7')
" call s:Highlight('typescriptClassName', 'CYAN_8', '', 'bold')
" call s:Highlight('typescriptDOMDocProp', 'YELLOW')
" call s:Highlight('typescriptDotNotation', 'TEAL_7')
" call s:Highlight('typescriptEndColons', 'TEAL_7')
" call s:Highlight('typescriptFuncCallArg', 'PURPLE_5')
" call s:Highlight('typescriptFuncKeyword', 'RED_5')
" call s:Highlight('typescriptInterfaceKeyword', 'GREEN_7')
" call s:Highlight('typescriptInterfaceName', 'CYAN_8', '', 'bold')
" call s:Highlight('typescriptMember', 'PURPLE_5')
" call s:Highlight('typescriptOperator', 'GREEN_7', '', 'bold')
" call s:Highlight('typescriptObjectLabel', 'PURPLE_5')
" call s:Highlight('typescriptParens', 'TEAL_7')
" call s:Highlight('typescriptPredefinedType', 'CYAN_8')
" call s:Highlight('typescriptStatementKeyword', 'GREEN', '', 'bold')
" call s:Highlight('typescriptTypeAnnotation', 'TEAL_7')
" call s:Highlight('typescriptTypeReference', 'CYAN_6')
" call s:Highlight('typescriptTypeBrackets', 'TEAL_7')
" call s:Highlight('typescriptVariableDeclaration', 'PURPLE_4')
" call s:Highlight('typescriptVariable', 'GREEN_7')
" This doesn't seem to apply v
call s:Highlight('typescriptIdentifierName', 'white', 'RED', 'bold')
call s:Highlight('typescriptProp', 'YELLOW', 'RED', 'bold')
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
call s:Highlight('markdownCodeDelimiter', 'BLUE')
call s:Highlight('markdownCode', 'BLUE')
call s:Highlight('markdownH1', 'GREEN_4', '', 'bold')
call s:Highlight('markdownH2', 'GREEN_5', '', 'bold')
call s:Highlight('markdownH3', 'GREEN_6', '', 'bold')
call s:Highlight('markdownH4', 'GREEN_7', '', 'bold')
call s:Highlight('markdownH5', 'GREEN_8', '', 'bold')
call s:Highlight('markdownH6', 'GREEN_9', '', 'bold')
call s:Highlight('markdownLinkDelimiter', 'YELLOW_8')
call s:Highlight('markdownLinkTextDelimiter', 'PURPLE_8')
call s:Highlight('markdownLinkText', 'PURPLE_5', '', 'underline')
call s:Highlight('markdownRule', 'TEAL')
call s:Highlight('markdownUrl', 'YELLOW')
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
call s:Highlight('rubyCurlyBlockDelimiter', 'ALIAS_PUNCTUATION')
call s:Highlight('rubyInterpolation', 'ALIAS_INTERPOLATION_VARIABLE')
call s:Highlight('rubyInterpolationDelimiter', 'ALIAS_INTERPOLATION_WRAPPER')
call s:Highlight('rubySymbol', 'ALIAS_SYMBOL')
" Following groups should be highlighted but aren't
call s:Highlight('rubyKeywordAsMethod', 'ALIAS_RED', 'RED')
" call s:Highlight('rubySymbol', 'ORANGE_5')
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
call s:Highlight('vimCommand', 'GREEN_7')
call s:Highlight('vimComment', 'ALIAS_COMMENT')
call s:Highlight('vimLet', 'RED_LIGHT')
call s:Highlight('vimFunction', 'YELLOW_6')
call s:Highlight('vimFunc', 'YELLOW_6')
call s:Highlight('vimOper', 'TEAL_7')
call s:Highlight('vimOperParen', 'TEAL_7')
call s:Highlight('vimOption', 'VIOLET', '', 'bold')
call s:Highlight('vimParenSep', 'TEAL_7')
call s:Highlight('vimSep', 'NEUTRAL')
call s:Highlight('vimSynType', 'YELLOW')
call s:Highlight('vimUserFunc', 'YELLOW')
call s:Highlight('vim9Comment', 'ALIAS_ERROR') " Comments using #
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
call s:Highlight('zshSubstDelim', 'ALIAS_INTERPOLATION_WRAPPER')
call s:Highlight('zshSwitches', 'ALIAS_FLAG')
call s:Highlight('zshTypes', 'ALIAS_VARIABLE_TYPE')
call s:Highlight('zshVariableDef', 'ALIAS_VARIABLE_DEFINITION')
call s:Highlight('zshVariable', 'ALIAS_VARIABLE_DEFINITION')

" call s:Highlight('ZinitIceModifiers', 'PURPLE_4')
" call s:Highlight('zshBrackets', 'TEAL_7')
" call s:Highlight('zshCommands', 'GREEN')
" call s:Highlight('zshConditional', 'EMERALD')
" call s:Highlight('zshDelimiter', 'EMERALD')
" call s:Highlight('zshDelim', 'TEAL_7')
" call s:Highlight('zshQuoted', 'BLUE_LIGHT')
" call s:Highlight('zshDeref', 'VIOLET')
" call s:Highlight('zshOptStart', 'GREEN_7', '', 'bold')
" call s:Highlight('zshOption', 'ORANGE', '', 'bold')
" call s:Highlight('zshParentheses', 'TEAL_7')
" call s:Highlight('zshRepeat', 'EMERALD')
" call s:Highlight('zshStringDelimiter', 'BLUE')
" call s:Highlight('zshSubst', 'YELLOW_6')
" call s:Highlight('zshVariable', 'ALIAS_VARIABLE')
" }}}





" Original palette {{{
" " Gray {{{
" let s:color.gray0='#808080'
" let s:color.gray1='#f7fafc'
" let s:color.gray2='#edf2f7'
" let s:color.gray3='#e2e8f0'
" let s:color.gray4='#cbd5e0'
" let s:color.gray5='#a0aec0'
" let s:color.gray6='#718096'
" let s:color.gray7='#4a5568'
" let s:color.gray8='#2d3748'
" let s:color.gray9='#1a202c'
" " }}}
" " Red {{{
" let s:color.red0='#ff0000'
" let s:color.red1='#fff5f5'
" let s:color.red2='#fed7d7'
" let s:color.red3='#feb2b2'
" let s:color.red4='#fc8181'
" let s:color.red5='#f56565'
" let s:color.red6='#e53e3e'
" let s:color.red7='#c53030'
" let s:color.red8='#9b2c2c'
" let s:color.red9='#742a2a'
" " }}}
" " Green {{{
" let s:color.green0='#00ff00'
" let s:color.green1='#f0fff4'
" let s:color.green2='#c6f6d5'
" let s:color.green3='#9ae6b4'
" let s:color.green4='#68d391'
" let s:color.green5='#48bb78'
" let s:color.green6='#38a169'
" let s:color.green7='#2f855a'
" let s:color.green8='#276749'
" let s:color.green9='#22543d'
" " }}}
" " Yellow {{{
" let s:color.yellow0='#ffff00'
" let s:color.yellow1='#fffff0'
" let s:color.yellow2='#fefcbf'
" let s:color.yellow3='#faf089'
" let s:color.yellow4='#f6e05e'
" let s:color.yellow5='#ecc94b'
" let s:color.yellow6='#d69e2e'
" let s:color.yellow7='#b7791f'
" let s:color.yellow8='#975a16'
" let s:color.yellow9='#744210'
" " }}}
" " Blue {{{
" let s:color.blue0='#0000ff'
" let s:color.blue1='#ebf8ff'
" let s:color.blue2='#bee3f8'
" let s:color.blue3='#90cdf4'
" let s:color.blue4='#63b3ed'
" let s:color.blue5='#4299e1'
" let s:color.blue6='#3182ce'
" let s:color.blue7='#2b6cb0'
" let s:color.blue8='#2c5282'
" let s:color.blue9='#2a4365'
" " }}}
" " Purple {{{
" let s:color.purple0='#ff00ff'
" let s:color.purple1='#faf5ff'
" let s:color.purple2='#e9d8fd'
" let s:color.purple3='#d6bcfa'
" let s:color.purple4='#b794f4'
" let s:color.purple5='#9f7aea'
" let s:color.purple6='#805ad5'
" let s:color.purple7='#6b46c1'
" let s:color.purple8='#553c9a'
" let s:color.purple9='#44337a'
" " }}}
" " Teal {{{
" let s:color.teal0='#00ffff'
" let s:color.teal1='#e6fffa'
" let s:color.teal2='#b2f5ea'
" let s:color.teal3='#81e6d9'
" let s:color.teal4='#4fd1c5'
" let s:color.teal5='#38b2ac'
" let s:color.teal6='#319795'
" let s:color.teal7='#2c7a7b'
" let s:color.teal8='#285e61'
" let s:color.teal9='#234e52'
" " }}}
" " Orange {{{
" let s:color.orange0='#ff8700'
" let s:color.orange1='#fffaf0'
" let s:color.orange2='#feebc8'
" let s:color.orange3='#fbd38d'
" let s:color.orange4='#ffaf00'
" let s:color.orange5='#ed8936'
" let s:color.orange6='#dd6b20'
" let s:color.orange7='#c05621'
" let s:color.orange8='#9c4221'
" let s:color.orange9='#7b341e'
" " }}}
" " Indigo {{{
" let s:color.indigo0='#5f00ff'
" let s:color.indigo1='#ebf4ff'
" let s:color.indigo2='#c3dafe'
" let s:color.indigo3='#a3bffa'
" let s:color.indigo4='#7f9cf5'
" let s:color.indigo5='#667eea'
" let s:color.indigo6='#5a67d8'
" let s:color.indigo7='#4c51bf'
" let s:color.indigo8='#434190'
" let s:color.indigo9='#3c366b'
" " }}}
" " Pink {{{
" let s:color.pink0='#d787ff'
" let s:color.pink1='#fff5f7'
" let s:color.pink2='#fed7e2'
" let s:color.pink3='#fbb6ce'
" let s:color.pink4='#f687b3'
" let s:color.pink5='#ed64a6'
" let s:color.pink6='#d53f8c'
" let s:color.pink7='#b83280'
" let s:color.pink8='#97266d'
" let s:color.pink9='#702459'
" " }}}
" }}}
