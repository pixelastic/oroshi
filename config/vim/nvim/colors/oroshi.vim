" Name:         Oroshi
" Maintainer:   Tim Carry <tim@pixelastic.com>
" "C'est parce qu'il y a 6 matières, c'est ca ?"
" "J'ai un coude chaud."

" Initialization {{{
" Needed for nvim to color the cursor
set background=dark
" Coloring current line
set cursorline
hi clear
if exists('syntax_on')
   syntax reset
endif
let g:colors_name = 'oroshi'
" }}}

" Defining the palette from the ENV variables {{{
let s:color = {}
" Build the s:color palette
for key in split($COLORS_INDEX, ' ')
   execute 'let s:color[key]=$COLOR_' . key . '_HEXA'
endfor
" }}}

" Defining the core highlight groups {{{
" Vim has its own set of core groups, and I have my own. They have a lot of
" overlap but some difference in naming (for example vim Delimiter is my
" PUNCTUATION). I will use my own naming when defining highlight group, which
" will internally be converted to vim naming.
" The key is my naming as defined in the $COLOR_ALIAS_XXX values, the values are
" {VimNaming}:{BackgroundColor}:{Boldness} I prefer to use existing core vim
" groups, but sometimes I need to create my own, prefixed with "oroshi"
let s:coreGroups = {
      \ 'BOOLEAN': 'Boolean:_:bold',
      \ 'COMMENT': 'Comment:_:_',
      \ 'CONSTANT': 'Constant:_:bold',
      \ 'DATE': 'oroshiDate:_:_',
      \ 'ERROR': 'Error:BLACK:bold',
      \ 'EVAL': 'oroshiEval:_:_',
      \ 'EXCEPTION': 'oroshiException:_:_',
      \ 'FILE': 'oroshiFile:_:_',
      \ 'FLAG': 'oroshiFlag:_:_',
      \ 'FUNCTION': 'Function:_:_',
      \ 'GIT_ADDED': 'oroshiGitAdded:_:_',
      \ 'GIT_BRANCH': 'oroshiGitBranch:_:_',
      \ 'GIT_MODIFIED': 'oroshiGitModified:_:_',
      \ 'GIT_REMOVED': 'oroshiGitRemoved:_:_',
      \ 'GLOB': 'oroshiGlob:_:_',
      \ 'HEADER': 'Title:_:_',
      \ 'IMPORT': 'oroshiImport:_:_',
      \ 'INTERPOLATION_STRING': 'oroshiInterpolationString:_:_',
      \ 'INTERPOLATION_VARIABLE': 'oroshiInterpolationVariable:_:_',
      \ 'INTERPOLATION_WRAPPER': 'oroshiInterpolationWrapper:_:_',
      \ 'KEY': 'oroshiKey:_:_',
      \ 'KEYWORD': 'Keyword:_:_',
      \ 'LINK': 'oroshiLink:_:underline',
      \ 'MODIFIER': 'oroshiModifier:_:_',
      \ 'NOISE': 'Noise:_:_',
      \ 'NOTICE': 'oroshiNotice:_:_',
      \ 'NUMBER': 'Number:_:bold',
      \ 'PUNCTUATION': 'Delimiter:_:_',
      \ 'REGEXP': 'oroshiRegexp:_:_',
      \ 'SPECIAL_CHAR': 'Special:_:_',
      \ 'STATEMENT': 'Statement:_:_',
      \ 'STRING': 'String:_:_',
      \ 'SUCCESS': 'oroshiSuccess:_:_',
      \ 'SYMBOL': 'oroshiSymbol:_:_',
      \ 'TERMINAL': 'oroshiTerminal:_:_',
      \ 'TEXT': 'Normal:_:_',
      \ 'TODO': 'Todo:_:bold',
      \ 'VARIABLE': 'Identifier:_:_',
      \ 'VARIABLE_DEFINITION': 'oroshiVariableDefinition:_:_',
      \ 'VARIABLE_TYPE': 'Type:_:_',
      \ 'WARNING': 'oroshiWarning:_:_',
      \ }

" Below are other core groups, that share coloring with the main ones. We will
" later link those secondary groups to the main ones
let s:secondaryCoreGroups= {
      \ 'PreProc': 'HEADER',
      \ 'Operator': 'PUNCTUATION',
      \ 'Conditional': 'STATEMENT',
      \ 'Repeat': 'STATEMENT',
      \ 'StorageClass': 'VARIABLE_TYPE',
      \ 'StringDelimiter': 'STRING',
      \ }
" }}}

" Highlighting function {{{
" args : group, foreground, background, decoration
function! s:Highlight(group,...)
  let name = get(a:, 'group')
  let foreground = get(a:, '1', '')
  let background = get(a:, '2', '')
  let decoration = get(a:, '3', '')

  " We clear all previous highlight, to start from a clean slate
  execute 'highlight clear '.name

  " Everything is empty, we stop now
  if foreground ==# '' && background ==# '' && decoration ==# ''
    return
  endif

  " We build the highlight string
  let result = 'hi! '.name
  let result .= ' guifg='.get(s:color, foreground, 'None')
  let result .= ' guibg='.get(s:color, background, 'None')
  if decoration !=# ''
    let result .= ' gui='.decoration
  endif

  execute result
endfunction
" Global wrapper function, available outside of this script
function! OroshiHighlight(arg,...)
  call s:Highlight(get(a:, 'arg'), get(a:, '1'), get(a:, '2'), get(a:, '3'))
endfunction
" }}}

" Linking function {{{
" Link a vim highlight definition group to own of our core colors
function! s:Link(vimGroupName, oroshiGroupName)
  execute 'highlight clear '. a:vimGroupName

  " Find the vim core group from the passed core group
  let s:coreGroupValue=s:coreGroups[a:oroshiGroupName]
  let s:split=split(s:coreGroupValue,':')
  let s:vimCoreGroupName=s:split[0]

  execute 'highlight! link '. a:vimGroupName .' '. s:vimCoreGroupName
endfunction
" }}}

" Highlight core groups {{{
" We highlight the core vim groups with our colors
for s:colorAliasName in keys(s:coreGroups)
  " Parse the value into its parts
  let s:colorDefinition=s:coreGroups[s:colorAliasName]
  let s:split=split(s:colorDefinition,':')
  let s:vimGroupName=s:split[0]
  let s:backgroundColor=s:split[1]
  let s:decoration=s:split[2]
  if s:backgroundColor ==# '_' | let s:backgroundColor='' | endif
  if s:decoration ==# '_' | let s:decoration='' | endif

  call s:Highlight(s:vimGroupName, 'ALIAS_' . s:colorAliasName, s:backgroundColor, s:decoration)
endfor
" }}}

" Linking secondary groups to core groups {{{
" We link other core vim groups to those groups
for s:secondaryGroupName in keys(s:secondaryCoreGroups)
  let s:coreGroupName=s:secondaryCoreGroups[s:secondaryGroupName]
  call s:Link(s:secondaryGroupName, s:coreGroupName)
endfor
" }}}

" Text {{{
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
call s:Highlight('TabLine', 'GRAY_4', 'GRAY_8', 'none')     " Tabs
call s:Highlight('TabLineSel', 'YELLOW', 'BLACK', 'bold')  " Current tab
call s:Highlight('TabLineSelSeparator', 'BLACK', 'GRAY_8', 'bold')  " Current tab
call s:Highlight('TabLineFill', 'GRAY_4', 'GRAY_8', 'none') " Rest of line
" Coloring the TabLine filetypes
for key in split($FILETYPES_INDEX, ' ')
  execute 'let filetypeColor=$FILETYPE_' . key . '_COLOR_NAME'
  call s:Highlight('TabLineFiletype_' . key, filetypeColor, 'GRAY_8')
  call s:Highlight('TabLineSelFiletype_' . key, filetypeColor, 'BLACK')
endfor
" }}}
" Cursor {{{
call s:Highlight('CursorLineNr', 'YELLOW', '', 'bold')
call s:Highlight('CursorLine', '', 'GRAY_9', 'none')

" Normal mode
call s:Highlight('CursorNormal', '', 'ALIAS_VIM_NORMAL_CURSOR', 'none')
let s:guicursor = 'n:block-CursorNormal'

" Waiting for an operator
call s:Highlight('CursorOperatorPending', '', 'RED_5', 'none')
let s:guicursor .= ',o:block-CursorOperatorPending'

" Insert mode
call s:Highlight('CursorInsert', '', 'ALIAS_VIM_INSERT_CURSOR', 'none')
let s:guicursor .= ',i:block-CursorInsert'

" Visual mode
call s:Highlight('CursorVisual', '', 'ALIAS_VIM_VISUAL_CURSOR', 'none')
let s:guicursor .= ',v:block-CursorVisual'

" Command mode
call s:Highlight('CursorCommand', '', 'ALIAS_VIM_COMMAND_CURSOR', 'none')
let s:guicursor .= ',c:block-CursorCommand'
" When editing the current command
call s:Highlight('CursorCommandInsert', '', 'ALIAS_VIM_COMMAND_CURSOR', 'none')
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
call s:Highlight('Visual', 'ALIAS_VIM_VISUAL_FOREGROUND', 'ALIAS_VIM_VISUAL_BACKGROUND', 'bold')
" }}}
" Search {{{
call s:Highlight('IncSearch', 'ALIAS_VIM_SEARCH_FOREGROUND', 'ALIAS_VIM_SEARCH_BACKGROUND', 'none')
call s:Highlight('Search', 'ALIAS_VIM_SEARCH_FOREGROUND', 'ALIAS_VIM_SEARCH_BACKGROUND', 'bold')
" }}}
" Completion {{{
call s:Highlight('Pmenu', 'GRAY_4', 'GRAY_9')            " Item
call s:Highlight('PmenuSel', 'YELLOW', 'GRAY_8', 'bold') " Selected item
call s:Highlight('PmenuSbar', 'GRAY_9', 'GRAY_9')        " Scrollbar
call s:Highlight('PmenuThumb', 'GRAY_8', 'GRAY_9')       " Scrollbar handle
" }}}
" ALE gutter {{{
call s:Link('ALEErrorSign', 'ERROR')
call s:Link('ALEWarningSign', 'WARNING')
" }}}
" GitGutter {{{
call s:Link('GitGutterAdd', 'GIT_ADDED')
call s:Link('GitGutterChange', 'GIT_MODIFIED')
call s:Link('GitGutterDelete', 'GIT_REMOVED')
" }}}
" Status line {{{
call s:Highlight('StatusLineLintError', 'RED', 'GRAY_8')
call s:Highlight('StatusLineLintWarning', 'YELLOW', 'GRAY_8')
call s:Highlight('StatusLineFileEncodingError', 'RED', 'GRAY_8')
call s:Highlight('StatusLineFileFormatError', 'RED', 'GRAY_8')
call s:Highlight('StatusLineGitClean', 'ALIAS_SUCCESS', 'GRAY_8')
call s:Highlight('StatusLineGitDirty', 'ALIAS_GIT_UNTRACKED', 'GRAY_8', 'bold')
call s:Highlight('StatusLineGitStaged', 'ALIAS_GIT_TRACKED', 'GRAY_8')
call s:Highlight('StatusLineModeInsertSeparator', 'YELLOW', 'GRAY_8')
call s:Highlight('StatusLineModeInsert', 'BLACK', 'YELLOW', 'bold')
call s:Highlight('StatusLineModeNormalSeparator', 'BLACK', 'GRAY_8')
call s:Highlight('StatusLineModeNormal', 'white', 'BLACK')
call s:Highlight('StatusLineModeSearchSeparator', 'ALIAS_VIM_SEARCH_BACKGROUND', 'ALIAS_VIM_SEARCH_FOREGROUND')
call s:Highlight('StatusLineModeSearch', 'ALIAS_VIM_SEARCH_FOREGROUND', 'ALIAS_VIM_SEARCH_BACKGROUND', 'bold')
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
  call s:Highlight('StatusLineFiletype_' . key, filetypeColor, 'GRAY_8')
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
" Matching parenthesis {{{
call s:Highlight('MatchParen', 'white', 'TEAL_9')
" }}}
" Messages {{{
call s:Link('ErrorMsg', 'ERROR')
call s:Link('WarningMsg', 'WARNING')
" }}}
" Spell Checking / Errors {{{
call s:Highlight('SpellBad', 'RED', 'BLACK', 'bold,underline')
call s:Highlight('SpellCap', 'RED', 'BLACK', 'bold,underline')
call s:Highlight('SpellLocal', 'VIOLET', 'BLACK', 'bold,underline')
call s:Highlight('SpellRare', 'GREEN', 'BLACK', 'bold,underline')

call s:Highlight('ALEError', '', 'RED_9')
call s:Highlight('ALEWarning', '', 'YELLOW_9')
" Below are other ALE highlight groups
" call s:Highlight('ALEInfo', '', 'RED')
" call s:Highlight('ALEStyleError', 'RED')
" call s:Highlight('ALEStyleWarning', 'RED')
" call s:Highlight('ALEVirtualTextError', 'RED')
" call s:Highlight('ALEVirtualTextStyleError', 'RED')
" call s:Highlight('ALEVirtualTextStyleWarning', 'RED')
" call s:Highlight('ALEVirtualTextWarning', 'RED')
" }}}

" AutoIt {{{
" call s:Highlight('autoitString', 'BLUE')
" call s:Highlight('autoitQuote', 'BLUE')
" call s:Highlight('autoitNumber', 'BLUE', '', 'bold')
" call s:Highlight('autoitParen', 'TEAL_7')
" call s:Highlight('autoitKeyword', 'GREEN_7')
" call s:Highlight('autoitVariable', 'PURPLE_4')
" call s:Highlight('autoitVarSelector', 'PURPLE_4', '', 'bold')
" call s:Highlight('autoitFunction', 'YELLOW')
" call s:Highlight('autoitBuiltin', 'YELLOW', '', 'bold')
" }}}
" CSS {{{
" call s:Highlight('cssVendor', 'ALIAS_WARNING')
" call s:Highlight('cssAttrComma', 'ALIAS_PUNCTUATION')
" call s:Highlight('cssSelectorOp', 'ALIAS_PUNCTUATION')
" call s:Highlight('scssAmpersand', 'ALIAS_MODIFIER')
" call s:Highlight('cssPseudoClassId', 'ALIAS_MODIFIER')
" call s:Highlight('cssBraces', 'ALIAS_PUNCTUATION')
" call s:Highlight('scssSelectorChar', 'ALIAS_PUNCTUATION')
" call s:Highlight('scssSelectorName', 'ALIAS_KEYWORD')
" call s:Highlight('cssAttr', 'ALIAS_TEXT')
" call s:Highlight('cssColor', 'ALIAS_SYMBOL')
" call s:Highlight('cssFontAttr', 'ALIAS_SYMBOL')
" call s:Highlight('cssCommonAttr', 'ALIAS_SYMBOL')
" call s:Highlight('cssBorderAttr', 'ALIAS_SYMBOL')
" call s:Highlight('cssTextAttr', 'ALIAS_SYMBOL')
" call s:Highlight('cssFlexibleBoxAttr', 'ALIAS_SYMBOL')
" call s:Highlight('cssPositioningAttr', 'ALIAS_SYMBOL')
" call s:Highlight('cssBackgroundAttr', 'ALIAS_SYMBOL')
" call s:Highlight('cssBoxAttr', 'ALIAS_SYMBOL')
" call s:Highlight('cssUIAttr', 'ALIAS_SYMBOL')
" call s:Highlight('cssUnitDecorators', 'ALIAS_PUNCTUATION')
" call s:Highlight('scssParameterList', 'ALIAS_PUNCTUATION')
" }}}
" Git {{{
" Git Config
call s:Link('gitconfigSection', 'HEADER')
" Git Commit
call s:Link('gitcommitDiff', 'COMMENT')
call s:Link('gitcommitBranch', 'GIT_BRANCH')
call s:Link('gitcommitHeader', 'COMMENT')
call s:Link('gitcommitSelectedFile', 'FILE')
" call s:Highlight('gitcommitDiscardedFile', 'ALIAS_FILE')
call s:Link('gitcommitSummary', 'TEXT')
" Git Diff
" call s:Link('gitDiff', 'COMMENT')
call s:Link('diffAdded', 'GIT_ADDED')
call s:Link('diffFile', 'HEADER')
call s:Link('diffLine', 'TERMINAL')
call s:Link('diffRemoved', 'GIT_REMOVED')
call s:Link('diffSubname', 'COMMENT')
" call s:Link('gitDiff', 'COMMENT')
" }}}
" HTML {{{
call s:Link('htmlTagName', 'KEYWORD')
call s:Link('htmlTag', 'PUNCTUATION')
call s:Link('htmlEndTag', 'PUNCTUATION')
call s:Link('htmlTitle', 'TEXT')
call s:Link('htmlh1', 'TEXT')
call s:Link('htmlh2', 'TEXT')
call s:Link('htmlh3', 'TEXT')
call s:Link('htmlh4', 'TEXT')
call s:Link('htmlh5', 'TEXT')
call s:Link('htmlh6', 'TEXT')
" call s:Highlight('htmlArg', 'ALIAS_VARIABLE_DEFINITION')
" call s:Highlight('htmlBold', 'NEUTRAL_LIGHT', '', 'bold')
" call s:Highlight('htmlItalic', 'NEUTRAL_LIGHT')
" call s:Highlight('htmlLink', 'ALIAS_TEXT')
" call s:Highlight('htmlSpecialChar', 'ALIAS_INTERPOLATION_VARIABLE')
" call s:Highlight('htmlSpecialTagName', 'ALIAS_KEYWORD')
" }}}
" JavaScript / TypeScript {{{
call s:Highlight('jsGlobalNodeObjects', 'ALIAS_FUNCTION', '', 'bold')
call s:Highlight('jsOperatorKeyword', 'ALIAS_FUNCTION', '', 'bold')
call s:Highlight('typescriptOperator', 'ALIAS_FUNCTION', '', 'bold')
call s:Highlight('typescriptExport', 'ALIAS_FUNCTION', '', 'bold')
call s:Link('jsTemplateBraces', 'INTERPOLATION_WRAPPER')
call s:Link('jsTemplateExpression', 'INTERPOLATION_VARIABLE')
call s:Link('jsVariableDef', 'VARIABLE')
call s:Link('jsObjectKey', 'KEY')
call s:Link('jsObjectValue', 'VARIABLE')
call s:Link('typescriptObjectLabel', 'KEY')
call s:Link('typescriptIdentifierName', 'VARIABLE')
call s:Link('typescriptAssign', 'PUNCTUATION')
call s:Link('typescriptDotNotation', 'PUNCTUATION')
call s:Link('typescriptBraces', 'PUNCTUATION')
call s:Link('typescriptParens', 'PUNCTUATION')
call s:Link('typescriptTypeBracket', 'PUNCTUATION')
call s:Link('typescriptTypeAnnotation', 'PUNCTUATION')
call s:Link('typescriptObjectColon', 'PUNCTUATION')
call s:Link('typescriptVariableDeclaration', 'VARIABLE')
call s:Link('typescriptVariable', 'VARIABLE_TYPE')
" }}}
" JSON {{{
call s:Link('jsonQuote', 'PUNCTUATION')
call s:Link('jsonKeywordMatch', 'PUNCTUATION')
call s:Link('jsonKeyword', 'VARIABLE')
" }}}
" JSONC {{{
" call s:Highlight('jsoncKeywordMatch', 'BLUE')
" augroup oroshi_jsonc
"   autocmd!
"   " The "Normal" highlight group is used for commas
"   autocmd FileType jsonc call s:Highlight('Normal', 'TEAL_7')
" augroup END
" }}}
" Markdown {{{
call s:Link('markdownCodeDelimiter', 'STRING')
call s:Link('markdownCode', 'STRING')
call s:Link('markdownCodeBlock', 'STRING')
call s:Link('markdownHeadingDelimiter', 'HEADER')
call s:Highlight('markdownH1', 'ALIAS_HEADER', '', 'bold')
call s:Link('markdownH2', 'HEADER')
call s:Link('markdownH3', 'HEADER')
call s:Link('markdownH4', 'HEADER')
call s:Link('markdownH5', 'HEADER')
call s:Link('markdownH6', 'HEADER')
" call s:Highlight('markdownListMarker', 'ALIAS_PUNCTUATION')
call s:Link('markdownLinkDelimiter', 'PUNCTUATION')
call s:Link('markdownLinkTextDelimiter', 'PUNCTUATION')
call s:Link('markdownLinkText', 'STRING')
call s:Link('markdownRule', 'PUNCTUATION')
call s:Link('markdownUrl', 'LINK')
" }}}
" Pug {{{
call s:Link('pugTag', 'FUNCTION')
call s:Link('pugClassChar', 'PUNCTUATION')
call s:Link('pugInlineDelimiter', 'INTERPOLATION_WRAPPER')
" call s:Highlight('pugJavascriptChar', 'ALIAS_EVAL')
" call s:Highlight('pugInterpolation', 'ALIAS_INTERPOLATION_VARIABLE')
" call s:Highlight('pugInterpolationDelimiter', 'ALIAS_INTERPOLATION_WRAPPER')
" call s:Link('pugAttributes', 'PUNCTUATION')
" }}}
" Python {{{
call s:Link('pythonStrInterpregion', 'INTERPOLATION_WRAPPER')
call s:Link('pythonOperator', 'STATEMENT')
" }}}
" Ruby {{{
" call s:Highlight('rubyDefine', 'ALIAS_VARIABLE_TYPE')
" call s:Highlight('rubyConstant', 'ALIAS_VARIABLE_DEFINITION')
" call s:Highlight('rubyClassName', 'ALIAS_VARIABLE_DEFINITION')
" call s:Highlight('rubyStringDelimiter', 'ALIAS_STRING')
" call s:Highlight('rubyArrayDelimiter', 'ALIAS_PUNCTUATION')
" call s:Highlight('rubyBlockParameterList', 'ALIAS_VARIABLE')
" call s:Highlight('rubyCurlyBlockDelimiter', 'ALIAS_PUNCTUATION')
" call s:Highlight('rubyInterpolation', 'ALIAS_INTERPOLATION_VARIABLE')
" call s:Highlight('rubyInterpolationDelimiter', 'ALIAS_INTERPOLATION_WRAPPER')
" call s:Highlight('rubySymbol', 'ALIAS_SYMBOL')
" " Following groups should be highlighted but aren't
" call s:Highlight('rubyKeywordAsMethod', 'RED', 'CYAN')
" }}}
" Shell {{{
call s:Link('shWrapLineOperator', 'SPECIAL_CHAR')
" call s:Highlight('shDerefSimple', 'ALIAS_INTERPOLATION_VARIABLE')
call s:Link('shOption', 'FLAG')
" call s:Highlight('shQuote', 'ALIAS_STRING')
" call s:Highlight('shRANGE', 'ALIAS_PUNCTUATION')
" call s:Highlight('shSetOption', 'ALIAS_FLAG')
" call s:Highlight('shSet', 'ALIAS_FUNCTION')
" call s:Highlight('shStatement', 'ALIAS_STATEMENT')
" call s:Highlight('shSemicolon', 'ALIAS_PUNCTUATION')
" }}}
" Tmux {{{
" call s:Highlight('tmuxBoolean', 'ORANGE', '', 'bold')
" call s:Highlight('tmuxCommands', 'YELLOW')
" call s:Highlight('tmuxFlags', 'ORANGE')
" call s:Highlight('tmuxOptions', 'VIOLET')
" call s:Highlight('tmuxKey', 'CYAN')
" call s:Highlight('tmuxFormatString', 'YELLOW')
" }}}
" Vim {{{
call s:Link('vim9Comment', 'ERROR') " Comments shouldn't start with #
" call s:Highlight('vimOption', 'ALIAS_VARIABLE')
" call s:Highlight('vimBracket', 'ALIAS_SPECIAL_CHAR')
" call s:Highlight('vimMapMod', 'ALIAS_SPECIAL_CHAR')
" call s:Highlight('vimMapLhs', 'ALIAS_SPECIAL_CHAR')
" call s:Highlight('vimMapRhs', 'ALIAS_FUNCTION')
" call s:Highlight('vimComment', 'ALIAS_COMMENT')
" call s:Highlight('vimLet', 'ALIAS_VARIABLE_TYPE')
" call s:Highlight('vimSetEqual', 'ALIAS_KEYWORD')
" call s:Highlight('vimSetSep', 'ALIAS_PUNCTUATION')
call s:Link('vimUserFunc', 'FUNCTION')
" }}}
" XML {{{
" call s:Highlight('xmlTag', 'ALIAS_PUNCTUATION')
" call s:Highlight('xmlEqual', 'ALIAS_PUNCTUATION')
" call s:Highlight('xmlDocTypeDecl', 'ALIAS_PUNCTUATION')
" call s:Highlight('xmlProcessingDelim', 'ALIAS_PUNCTUATION')
" call s:Highlight('xmlTagName', 'ALIAS_KEYWORD')
" call s:Highlight('xmlAttrib', 'ALIAS_VARIABLE')
" }}}
" Yaml {{{
call s:Link('yamlPlainScalar', 'STRING')
call s:Link('yamlAlias', 'FUNCTION')
" call s:Highlight('yamlBlockCollectionItemStart', 'TEAL_7')
" call s:Highlight('yamlFlowString', 'BLUE')
call s:Link('yamlKeyValueDelimiter', 'PUNCTUATION')
call s:Link('yamlBlockCollectionItemStart', 'PUNCTUATION')
" }}}
" Zsh {{{
call s:Link('shStatement', 'FUNCTION')
call s:Link('zshCommands', 'FUNCTION')
call s:Link('zshSubstDelim', 'INTERPOLATION_WRAPPER')
call s:Link('zshSwitches', 'FLAG')
call s:Link('zshVariableDef', 'VARIABLE_DEFINITION')
call s:Link('zshVariable', 'VARIABLE_DEFINITION')
" call s:Highlight('zshDereferencing', 'ALIAS_VARIABLE')
" call s:Highlight('zshKSHFunction', 'ALIAS_VARIABLE_DEFINITION')
" call s:Highlight('zshKeyword', 'ALIAS_VARIABLE_TYPE')
" call s:Highlight('zshSubst', 'ALIAS_INTERPOLATION_VARIABLE')
" call s:Highlight('zshTypes', 'ALIAS_VARIABLE_TYPE')
" }}}
" }}}
