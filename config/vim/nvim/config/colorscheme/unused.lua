local hl = F.hl

-- In this file, I list all Highlight groups that I haven't defined yet, and I
-- set them as XXX (which results in a noticable CYAN background).
--
-- If I see something looking like this, I go to this file, and change the XXX
-- to YYY (turning it purple, can be done with Ctrl-X easily) until I find the
-- right group.
--
-- Once found, I move it to the relevant file, and tweak it as I need it. Over
-- time, this file will get less and less entries, as I identify them all.


-- UI groups {{{
hl('CmpItemAbbrDeprecated', 'XXX')
hl('CmpItemMenu', 'XXX')
hl('PmenuExtraSel', 'XXX') --	Popup menu: Selected item "extra text".
hl('PmenuExtra', 'XXX') --	Popup menu: Normal item "extra text".
hl('PmenuKindSel', 'XXX') --	Popup menu: Selected item "kind".
hl('PmenuKind', 'XXX') --	Popup menu: Normal item "kind".
hl('ComplMatchIns', 'XXX') --	Matched text of the currently inserted completion.
hl('CursorColumn', 'XXX') --	Screen-column at the cursor, when 'cursorcolumn' is set.
hl('CursorIM', 'XXX') --	Like Cursor, but used when in IME mode. *CursorIM*
hl('Cursor', 'XXX') --		Character under the cursor.
hl('FloatFooter', 'XXX') --	Footer of floating windows.
hl('LineNrAbove', 'XXX') --	Line number for when the 'relativenumber'
hl('LineNrBelow', 'XXX') --	Line number for when the 'relativenumber'
hl('ModeMsg', 'XXX') --		'showmode' message (e.g., "-- INSERT --").
hl('MsgSeparator', 'XXX') --	Top bar separator of messsage
hl('QuickFixLine', 'XXX') --	Current |quickfix| item in the quickfix window. Combined with
hl('SnippetTabstop', 'XXX') --	Tabstops in snippets. |vim.snippet|
hl('SpellBad', 'XXX') --	Word that is not recognized by the spellchecker. |spell|
hl('SpellCap', 'XXX') --	Word that should start with a capital. |spell|
hl('SpellLocal', 'XXX') --	Word that is recognized by the spellchecker as one that is
hl('SpellRare', 'XXX') --	Word that is recognized by the spellchecker as one that is
hl('StatusLineTermNC', 'XXX') --
hl('StatusLineTerm', 'XXX') --	Status line of |terminal| window.
hl('Substitute', 'XXX') --	|:substitute| replacement text highlighting.
hl('TabLineSelSeparator', 'XXX') --	Tab pages line, active tab page label.
hl('TabLineSel', 'XXX') --	Tab pages line, active tab page label.
hl('TabLine', 'XXX') --		Tab pages line, not active tab page label.
hl('TermCursor', 'XXX') --	Cursor in a focused terminal.
hl('WarningMsg', 'XXX') --	Warning messages.
hl('WildMenu', 'XXX') --	Current match in 'wildmenu' completion.
hl('lCursor', 'XXX') --		Character under the cursor when |language-mapping|
-- }}}

-- Syntax groups {{{
hl('Character', 'XXX') --	a character constant: 'c', '\n'
hl('Debug', 'XXX') --		debugging statements
hl('Define', 'XXX') --		preprocessor #define
hl('Exception', 'XXX') --	try, catch, throw
hl('Float', 'XXX') --		a floating point constant: 2.3e10
hl('Ignore', 'XXX') --		left blank, hidden  |hl-Ignore|
hl('Macro', 'XXX') --		same as Define
hl('PreCondit', 'XXX') --	preprocessor #if, #else, #endif, etc.
hl('SpecialComment', 'XXX') --	special things inside a comment
hl('Typedef', 'XXX') --		a typedef
-- }}}

-- Cursors {{{
hl('CursorModeVisualExclusive', 'XXX')
hl('CursorModeOperator', 'XXX')
hl('CursorModeReplace', 'XXX')
hl('CursorModeCommandReplace', 'XXX')
hl('CursorModeShowMatch', 'XXX')
hl('CursorModeCommandInsert', 'XXX')
-- }}}

-- Diagnostics {{{
hl('DiagnosticDeprecated', 'XXX')
hl('DiagnosticFloatingError', 'XXX')
hl('DiagnosticFloatingHint', 'XXX')
hl('DiagnosticFloatingInfo', 'XXX')
hl('DiagnosticFloatingOk', 'XXX')
hl('DiagnosticFloatingWarn', 'XXX')
hl('DiagnosticOk', 'XXX')
hl('DiagnosticSignOk', 'XXX')
hl('DiagnosticVirtualTextOk', 'XXX')
hl('DiagnosticUnderlineOk', 'XXX')
hl('DiagnosticSignError', 'XXX')
hl('DiagnosticSignWarn', 'XXX')
hl('DiagnosticSignInfo', 'XXX')
hl('DiagnosticSignHint', 'XXX')
-- }}}

-- Render Markdown plugin {{{
hl('RenderMarkdownQuote', 'XXX') -- 	Default for block quote
hl('RenderMarkdownQuote2', 'XXX') -- 	Level 2 block quote marker
hl('RenderMarkdownQuote3', 'XXX') -- 	Level 3 block quote marker
hl('RenderMarkdownQuote4', 'XXX') -- 	Level 4 block quote marker
hl('RenderMarkdownQuote5', 'XXX') -- 	Level 5 block quote marker
hl('RenderMarkdownQuote6', 'XXX') -- 	Level 6 block quote marker
hl('RenderMarkdownInlineHighlight', 'XXX') -- 	Inline highlights contents
hl('RenderMarkdownMath', 'XXX') -- 	Latex lines
hl('RenderMarkdownIndent', 'XXX') -- 	Indent icon
hl('RenderMarkdownHtmlComment', 'XXX') -- 	HTML comment inline text
hl('RenderMarkdownWikiLink', 'XXX') -- 	WikiLink icon & text
hl('RenderMarkdownUnchecked', 'XXX') -- 	Unchecked checkbox
hl('RenderMarkdownChecked', 'XXX') -- 	Checked checkbox
hl('RenderMarkdownTodo', 'XXX') -- 	Todo custom checkbox
hl('RenderMarkdownTableHead', 'XXX') -- 	Pipe table heading rows
hl('RenderMarkdownTableRow', 'XXX') -- 	Pipe table body rows
hl('RenderMarkdownTableFill', 'XXX') -- 	Pipe table inline padding
hl('RenderMarkdownSuccess', 'XXX') -- 	Success related callouts
hl('RenderMarkdownInfo', 'XXX') -- 	Info related callouts
hl('RenderMarkdownHint', 'XXX') -- 	Hint related callouts
hl('RenderMarkdownWarn', 'XXX') -- 	Warning related callouts
hl('RenderMarkdownError', 'XXX') -- 	Error related callouts
-- }}}

-- GitSigns {{{
hl('GitSignsAddCul', 'XXX')
hl('GitSignsAdd', 'XXX')
hl('GitSignsChangeCul', 'XXX')
hl('GitSignsChangedeleteCul', 'XXX')
hl('GitSignsChangedeleteLn', 'XXX')
hl('GitSignsChangedelete', 'XXX')
hl('GitSignsChange', 'XXX')
hl('GitSignsDeleteCul', 'XXX')
hl('GitSignsDelete', 'XXX')
hl('GitSignsTopdeleteCul', 'XXX')
hl('GitSignsTopdelete', 'XXX')
hl('GitSignsUntrackedCul', 'XXX')
hl('GitSignsUntrackedLn', 'XXX')
hl('GitSignsUntracked', 'XXX')
-- }}}

-- Avante {{{
hl('AvanteButtonPrimary', 'XXX')
hl('AvanteButtonPrimaryHover', 'XXX')
hl('AvanteButtonDanger', 'XXX')
hl('AvanteButtonDangerHover', 'XXX')
hl('AvanteSuggestion', 'XXX')
hl('AvanteAnnotation', 'XXX')
hl('AvanteToBeDeleted', 'XXX')
hl('AvanteReversedNormal', 'XXX')
hl('AvanteStateSpinnerSearching', 'XXX')
hl('AvanteStateSpinnerThinking', 'XXX')
hl('AvanteStateSpinnerCompacting', 'XXX')
hl('AvanteConflictCurrent', 'XXX')
-- }}}

-- Noice {{{

hl('NoiceCmdlineIconCalculator', 'XXX')
hl('NoiceCmdlineIconIncRename', 'XXX')
hl('NoiceCmdlineIconInput', 'XXX')
hl('NoiceCmdlineIcon', 'XXX')
hl('NoiceCmdlinePopupBorderCalculator', 'XXX')
hl('NoiceCmdlinePopupBorderIncRename', 'XXX')
hl('NoiceCmdlinePopupBorder', 'XXX')
hl('NoiceCmdlinePopupTitle', 'XXX')
hl('NoiceCmdline', 'XXX')
hl('NoiceCompletionItemKindClass', 'XXX')
hl('NoiceCompletionItemKindColor', 'XXX')
hl('NoiceCompletionItemKindConstant', 'XXX')
hl('NoiceCompletionItemKindConstructor', 'XXX')
hl('NoiceCompletionItemKindDefault', 'XXX')
hl('NoiceCompletionItemKindEnumMember', 'XXX')
hl('NoiceCompletionItemKindEnum', 'XXX')
hl('NoiceCompletionItemKindField', 'XXX')
hl('NoiceCompletionItemKindFile', 'XXX')
hl('NoiceCompletionItemKindFolder', 'XXX')
hl('NoiceCompletionItemKindFunction', 'XXX')
hl('NoiceCompletionItemKindInterface', 'XXX')
hl('NoiceCompletionItemKindKeyword', 'XXX')
hl('NoiceCompletionItemKindMethod', 'XXX')
hl('NoiceCompletionItemKindModule', 'XXX')
hl('NoiceCompletionItemKindProperty', 'XXX')
hl('NoiceCompletionItemKindSnippet', 'XXX')
hl('NoiceCompletionItemKindStruct', 'XXX')
hl('NoiceCompletionItemKindText', 'XXX')
hl('NoiceCompletionItemKindUnit', 'XXX')
hl('NoiceCompletionItemKindValue', 'XXX')
hl('NoiceCompletionItemKindVariable', 'XXX')
hl('NoiceCompletionItemMenu', 'XXX')
hl('NoiceConfirmBorder', 'XXX')
hl('NoiceConfirm', 'XXX')
hl('NoiceCursor', 'XXX')
hl('NoiceFormatConfirmDefault', 'XXX')
hl('NoiceFormatConfirm', 'XXX')
hl('NoiceFormatLevelOff', 'XXX')
hl('NoiceFormatLevelTrace', 'XXX')
hl('NoiceFormatLevelWarn', 'XXX')
hl('NoiceFormatProgressDone', 'XXX')
hl('NoiceFormatProgressTodo', 'XXX')
hl('NoiceFormatTitle', 'XXX')
hl('NoiceLspProgressClient', 'XXX')
hl('NoiceLspProgressSpinner', 'XXX')
hl('NoiceLspProgressTitle', 'XXX')
hl('NoicePopupBorder', 'XXX')
hl('NoicePopupmenuBorder', 'XXX')
hl('NoicePopup', 'XXX')
hl('NoiceSplitBorder', 'XXX')
hl('NoiceVirtualText', 'XXX')
-- }}}

-- Mini.pick {{{
hl('MiniPickBorderBusy', 'XXX')
hl('MiniPickBorderText', 'XXX')
hl('MiniPickBorder', 'XXX')
hl('MiniPickCursor', 'XXX')
hl('MiniPickHeader', 'XXX')
hl('MiniPickIconDirectory', 'XXX')
hl('MiniPickIconFile', 'XXX')
hl('MiniPickMatchCurrent', 'XXX')
hl('MiniPickMatchMarked', 'XXX')
hl('MiniPickMatchRanges', 'XXX')
hl('MiniPickNormal', 'XXX')
hl('MiniPickPreviewLine', 'XXX')
hl('MiniPickPreviewRegion', 'XXX')
hl('MiniPickPromptCaret', 'XXX')
hl('MiniPickPromptPrefix', 'XXX')
hl('MiniPickPrompt', 'XXX')
-- }}}

-- CodeCompanion {{{
hl('CodeCompanionChatInfo', 'XXX')
hl('CodeCompanionChatError', 'XXX')
hl('CodeCompanionChatWarn', 'XXX')
hl('CodeCompanionChatSubtext', 'XXX')
hl('CodeCompanionChatHeader', 'XXX')
hl('CodeCompanionChatSeparator', 'XXX')
hl('CodeCompanionChatTokens', 'XXX')
hl('CodeCompanionChatTool', 'XXX')
hl('CodeCompanionChatToolGroups', 'XXX')
hl('CodeCompanionVirtualText', 'XXX')
-- }}}
