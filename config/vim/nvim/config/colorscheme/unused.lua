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
hl('ComplMatchIns', 'XXX') --	Matched text of the currently inserted completion.
hl('Conceal', 'XXX') --		Placeholder characters substituted for concealed
hl('CursorColumn', 'XXX') --	Screen-column at the cursor, when 'cursorcolumn' is set.
hl('CursorIM', 'XXX') --	Like Cursor, but used when in IME mode. *CursorIM*
hl('CursorLineFold', 'XXX') --	Like FoldColumn when 'cursorline' is set for the cursor line.
hl('Cursor', 'XXX') --		Character under the cursor.
hl('DiffAdd', 'XXX') --		Diff mode: Added line. |diff.txt|
hl('DiffChange', 'XXX') --	Diff mode: Changed line. |diff.txt|
hl('DiffDelete', 'XXX') --	Diff mode: Deleted line. |diff.txt|
hl('DiffText', 'XXX') --	Diff mode: Changed text within a changed line. |diff.txt|

hl('FloatBorder', 'YYY') --	Border of floating windows.
hl('FloatFooter', 'YYY') --	Footer of floating windows.
hl('FloatTitle', 'YYY') --	Title of floating windows.
hl('FoldColumn', 'YYY') --	'foldcolumn'
hl('LineNrAbove', 'YYY') --	Line number for when the 'relativenumber'
hl('LineNrBelow', 'YYY') --	Line number for when the 'relativenumber'

hl('ModeMsg', 'YYY') --		'showmode' message (e.g., "-- INSERT --").
hl('NormalFloat', 'YYY') --	Normal text in floating windows.
hl('DiagnosticInfo', 'YYY')

hl('QuickFixLine', 'XXX') --	Current |quickfix| item in the quickfix window. Combined with
hl('SnippetTabstop', 'XXX') --	Tabstops in snippets. |vim.snippet|

hl('SpellBad', 'YYY') --	Word that is not recognized by the spellchecker. |spell|
hl('SpellCap', 'YYY') --	Word that should start with a capital. |spell|
hl('SpellLocal', 'YYY') --	Word that is recognized by the spellchecker as one that is
hl('SpellRare', 'YYY') --	Word that is recognized by the spellchecker as one that is
hl('StatusLineTermNC', 'YYY') --
hl('StatusLineTerm', 'YYY') --	Status line of |terminal| window.
hl('Substitute', 'YYY') --	|:substitute| replacement text highlighting.
hl('TabLineSelSeparator', 'YYY') --	Tab pages line, active tab page label.
hl('TabLineSel', 'YYY') --	Tab pages line, active tab page label.
hl('TabLine', 'YYY') --		Tab pages line, not active tab page label.
hl('TermCursor', 'YYY') --	Cursor in a focused terminal.
hl('WarningMsg', 'YYY') --	Warning messages.
hl('WildMenu', 'YYY') --	Current match in 'wildmenu' completion.
hl('WinBarNC', 'YYY') --	Window bar of not-current windows.
hl('WinBar', 'YYY') --		Window bar of current window.
hl('lCursor', 'YYY') --		Character under the cursor when |language-mapping|
-- }}}

-- Syntax groups {{{
hl('Added', 'XXX') --		added line in a diff
hl('Changed', 'XXX') --		changed line in a diff
hl('Character', 'XXX') --	a character constant: 'c', '\n'
hl('Debug', 'XXX') --		debugging statements
hl('Define', 'XXX') --		preprocessor #define
hl('Exception', 'XXX') --	try, catch, throw
hl('Float', 'XXX') --		a floating point constant: 2.3e10
hl('Ignore', 'XXX') --		left blank, hidden  |hl-Ignore|
hl('Label', 'XXX') --		case, default, etc.
hl('Macro', 'XXX') --		same as Define
hl('PreCondit', 'XXX') --	preprocessor #if, #else, #endif, etc.
hl('Removed', 'XXX') --		removed line in a diff
hl('SpecialComment', 'XXX') --	special things inside a comment
hl('Tag', 'XXX') --		you can use CTRL-] on this
hl('Typedef', 'XXX') --		a typedef
-- }}}

-- Notify {{{
hl('NotifyINFOIcon', 'XXX')
hl('NotifyINFOTitle', 'XXX')
hl('NotifyDEBUGBorder', 'XXX')
hl('NotifyWARNBorder', 'XXX')
hl('NotifyERRORBorder', 'XXX')
hl('NotifyTRACEBorder', 'XXX')
hl('NotifyERRORIcon', 'XXX')
hl('NotifyWARNIcon', 'XXX')
hl('NotifyDEBUGIcon', 'XXX')
hl('NotifyTRACEIcon', 'XXX')
hl('NotifyERRORTitle', 'XXX')
hl('NotifyWARNTitle', 'XXX')
hl('NotifyDEBUGTitle', 'XXX')
hl('NotifyTRACETitle', 'XXX')
hl('NotifyERRORBody', 'XXX')
hl('NotifyWARNBody', 'XXX')
hl('NotifyDEBUGBody', 'XXX')
hl('NotifyTRACEBody', 'XXX')
-- }}}

-- Render Markdown plugin {{{
hl('RenderMarkdownQuote', 'XXX') -- 	Default for block quote
hl('RenderMarkdownQuote1', 'XXX') -- 	Level 1 block quote marker
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
