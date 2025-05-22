-- Name:         Oroshi
-- Maintainer:   Tim Carry <tim@pixelastic.com>
-- "C'est parce qu'il y a 6 matières, c'est ca ?"
-- "J'ai un coude chaud."

vim.cmd('highlight clear')
if vim.g.syntax_on then
    vim.cmd('syntax reset')
end

vim.opt.background = "dark"     -- Prefer dark mode
vim.g.colors_name = "irisho"

-- Palette {{{
local function getPalette()
  local palette = {}

  local env_COLORS_INDEX = os.getenv('COLORS_INDEX')
  local items = vim.split(env_COLORS_INDEX, " ", { trimempty = true })
  for _, item in ipairs(items) do
    local key = string.gsub(item, 'ALIAS_', '')
    local value = os.getenv('COLOR_' .. item .. '_HEXA')
    palette[key] = value
  end
  return palette
end
vim.g.palette = getPalette()
-- }}}

-- Functions {{{
local function hl(groupName, colorName, options)
  local defaults = { 
    fg = vim.g.palette[colorName],
    bg = "none",
    bold = false,
    italic = false,
  }
  local config = vim.tbl_deep_extend("force", defaults, options or {})

  -- Use color alias for background
  if config.bg ~= 'none' then
    config.bg = vim.g.palette[config.bg]
  end

  -- make XXX and YYY standout
  if colorName == 'XXX' then
    config = {
      fg = vim.g.palette.WHITE,
      bg = vim.g.palette.CYAN,
      bold = true,
    }
  end
  if colorName == 'YYY' then
    config = {
      fg = vim.g.palette.WHITE,
      bg = vim.g.palette.PURPLE,
    }
  end


  vim.api.nvim_set_hl(0, groupName, config)
end
-- }}}


-- Standard Syntax Groups {{{
hl('Added', 'XXX') --		added line in a diff
hl('Boolean', 'BOOLEAN', { bold = true })
hl('Changed', 'XXX') --		changed line in a diff
hl('Character', 'XXX') --	a character constant: 'c', '\n'
hl('Comment', 'COMMENT')
hl('Conditional', 'STATEMENT') --	if, then, else, endif, switch, etc.
hl('Constant', 'CONSTANT', { bold = true }) 
hl('Debug', 'XXX') --		debugging statements
hl('Define', 'XXX') --		preprocessor #define
hl('Delimiter', 'PUNCTUATION') 
hl('Error', 'ERROR', { bold = true }) 
hl('Exception', 'XXX') --	try, catch, throw
hl('Float', 'XXX') --		a floating point constant: 2.3e10
hl('Function', 'FUNCTION') 
hl('Identifier', 'VARIABLE') 
hl('Ignore', 'XXX') --		left blank, hidden  |hl-Ignore|
hl('Include', 'XXX') --		preprocessor #include
hl('Keyword', 'KEYWORD') 
hl('Label', 'XXX') --		case, default, etc.
hl('Macro', 'XXX') --		same as Define
hl('Number', 'NUMBER', { bold = true }) 
hl('Operator', 'PUNCTUATION') --	"sizeof", "+", "*", etc.
hl('PreCondit', 'XXX') --	preprocessor #if, #else, #endif, etc.
hl('PreProc', 'HEADER') --		generic Preprocessor
hl('Removed', 'XXX') --		removed line in a diff
hl('Repeat', 'STATEMENT') --		for, do, while, etc.
hl('SpecialChar', 'SPECIAL_CHAR') --	special character in a constant
hl('SpecialComment', 'XXX') --	special things inside a comment
hl('Special', 'SPECIAL_CHAR') 
hl('SpecialKey', 'SPECIAL_CHAR') -- Unprintable characters
hl('Statement', 'STATEMENT') 
hl('StorageClass', 'VARIABLE_TYPE') --	static, register, volatile, etc.
hl('String', 'STRING') 
hl('Structure', 'VARIABLE_TYPE') --	struct, union, enum, etc.
hl('Tag', 'XXX') --		you can use CTRL-] on this
hl('Todo', 'TODO', { bold = true }) 
hl('Typedef', 'XXX') --		a typedef
hl('Type', 'VARIABLE_TYPE') 
hl('Underlined', 'none', { underline = true }) --	text that stands out, HTML links
-- }}}

-- Standard UI groups {{{
-- Cursor
hl('CursorColumn', 'XXX') --	Screen-column at the cursor, when 'cursorcolumn' is set.
hl('CursorIM', 'XXX') --	Like Cursor, but used when in IME mode. *CursorIM*
hl('Cursor', 'XXX') --		Character under the cursor.
-- Diff
hl('DiffAdd', 'XXX') --		Diff mode: Added line. |diff.txt|
hl('DiffChange', 'XXX') --	Diff mode: Changed line. |diff.txt|
hl('DiffDelete', 'XXX') --	Diff mode: Deleted line. |diff.txt|
hl('DiffText', 'XXX') --	Diff mode: Changed text within a changed line. |diff.txt|
-- Messages
hl('ErrorMsg', 'XXX') --	Error messages on the command line.
-- Windows
hl('FloatBorder', 'XXX') --	Border of floating windows.
hl('FloatFooter', 'XXX') --	Footer of floating windows.
hl('FloatTitle', 'XXX') --	Title of floating windows.
-- Fold
hl('FoldColumn', 'XXX') --	'foldcolumn'
-- PMenu
hl('PmenuExtraSel', 'XXX') --	Popup menu: Selected item "extra text".
hl('PmenuExtra', 'XXX') --	Popup menu: Normal item "extra text".
hl('PmenuKindSel', 'XXX') --	Popup menu: Selected item "kind".
hl('PmenuKind', 'XXX') --	Popup menu: Normal item "kind".
hl('PmenuMatchSel', 'XXX') --	Popup menu: Matched text in selected item. Combined with
hl('PmenuMatch', 'XXX') --	Popup menu: Matched text in normal item. Combined with
hl('PmenuSbar', 'XXX') --	Popup menu: Scrollbar.
hl('PmenuThumb', 'XXX') --	Popup menu: Thumb of the scrollbar.
hl('CmpItemKind', 'XXX')
hl('CmpItemAbbrDeprecated', 'XXX')
hl('CmpItemAbbrMatchFuzzy', 'XXX')
hl('CmpItemMenu', 'XXX')


hl('WildMenu', 'XXX') --	Current match in 'wildmenu' completion.
hl('Conceal', 'XXX') --		Placeholder characters substituted for concealed
hl('NormalFloat', 'XXX') --	Normal text in floating windows.
hl('ComplMatchIns', 'XXX') --	Matched text of the currently inserted completion.
hl('LineNrAbove', 'XXX') --	Line number for when the 'relativenumber'
hl('LineNrBelow', 'XXX') --	Line number for when the 'relativenumber'
hl('MoreMsg', 'XXX') --		|more-prompt|
hl('MsgSeparator', 'XXX') --	Separator for scrolled messages |msgsep|.
hl('NonText', 'GRAY_8') --		'@' at the end of the window, characters from 'showbreak'
hl('Question', 'XXX') --	|hit-enter| prompt and yes/no questions.
hl('QuickFixLine', 'XXX') --	Current |quickfix| item in the quickfix window. Combined with
hl('SnippetTabstop', 'XXX') --	Tabstops in snippets. |vim.snippet|
hl('SpellBad', 'XXX') --	Word that is not recognized by the spellchecker. |spell|
hl('SpellCap', 'XXX') --	Word that should start with a capital. |spell|
hl('SpellLocal', 'XXX') --	Word that is recognized by the spellchecker as one that is
hl('SpellRare', 'XXX') --	Word that is recognized by the spellchecker as one that is
hl('Substitute', 'XXX') --	|:substitute| replacement text highlighting.
hl('TermCursor', 'XXX') --	Cursor in a focused terminal.
hl('Title', 'HEADER') --		Titles for output from ":set all", ":autocmd" etc.
hl('WarningMsg', 'XXX') --	Warning messages.
hl('Whitespace', 'YELLOW') --	"nbsp", "space", "tab", "multispace", "lead" and "trail"
hl('WinBarNC', 'XXX') --	Window bar of not-current windows.
hl('WinBar', 'XXX') --		Window bar of current window.
hl('lCursor', 'XXX') --		Character under the cursor when |language-mapping|
hl('CursorLineFold', 'XXX') --	Like FoldColumn when 'cursorline' is set for the cursor line.
-- }}}

-- UI {{{
hl('Normal', 'TEXT') --		Normal text.
hl('ColorColumn', 'none', { bg = 'GRAY_9'}) --	Max column
hl('EndOfBuffer', 'BLACK') --	Filler lines (~) after the end of the buffer.
-- }}}

-- Files
hl('Directory', 'DIRECTORY') --	Directory names 

-- Tabs {{{
hl('TabLine', 'GRAY_4', { bg = 'GRAY_8' }) --		Tab pages line, not active tab page label.
hl('TabLineSel', 'YELLOW', { bg = 'BLACK', bold = true }) --	Tab pages line, active tab page label.
hl('TabLineSelSeparator', 'BLACK', { bg = 'GRAY_8', bold = true }) --	Tab pages line, active tab page label.
hl('TabLineFill', 'GRAY_4', { bg = 'GRAY_8' }) --	Tab pages line, where there are no labels.
-- }}}

-- Splits {{{
hl('WinSeparator', 'YELLOW_9', { bg = 'BLACK', bold = true }) --	Separators between splits
-- hl('NormalNC', 'none', { bg = 'GRAY_8' }) --	Normal text in non-current windows.
hl('StatusLineNC', 'none', { bg = 'GRAY_8' }) --	Status lines of not-current windows.
hl('StatusLineTermNC', 'XXX') --
-- }}}

-- Line Number {{{
hl('LineNr', 'GRAY') --	Line number column
hl('SignColumn', 'GRAY') --	Sign column
-- }}}

-- Folds {{{
hl('Folded', 'none', { bg = 'GRAY_8'}) --	Closed fold
-- }}}

-- Misc {{'
hl('MatchParen', 'YELLOW', { bg = 'PUNCTUATION' }) -- Matching parenthesis
-- }}}

-- Cursor {{{
hl('CursorLine', 'none', { bg = 'GRAY_9' }) --	Current line
hl('CursorLineNr', 'YELLOW', { bg = 'GRAY_9', bold = true }) --	Current line number
hl('CursorLineSign', 'none', { bg = 'GRAY_9'}) --	Current line sign
-- }}}

-- Visual mode {{{
hl('Visual', 'VIM_VISUAL_FOREGROUND', { bg = 'VIM_VISUAL_BACKGROUND', bold = true }) --		Visual mode selection.
-- }}}

-- Search mode {{{
hl('IncSearch', 'BLACK', { bg = 'YELLOW_4', bold = true }) -- Match as I type
hl('CurSearch', 'BLACK', { bg = 'YELLOW_4', bold = true }) --	Current selected match
hl('Search', 'BLACK', { bg = 'YELLOW_6', bold = true }) -- All results
-- }}}

-- Statusline {{{
hl('StatusLineTerm', 'XXX') --	Status line of |terminal| window.
hl('StatusLine', 'GRAY_4', { bg = 'YELLOW' }) --	Status line of current window.
-- }}}

-- Completion
hl('Pmenu', 'BLACK', { bg = 'BLACK'})       -- Background
hl('CmpItemAbbr', 'BLACK') -- Suggestions
hl('PmenuSel', 'BLACK') -- Current selection
hl('CmpItemAbbrMatch', 'BLACK') -- Partial match
-- }}}

-- Commandline {{{
hl('ModeMsg', 'XXX') --		'showmode' message (e.g., "-- INSERT --").
hl('MsgArea', 'TEXT', { bg = 'NONE' }) -- Where messages are displayed
-- }}}

-- Custom groups {{{
hl('Noise', 'NOISE') 
-- }}}

-- TreeSitter {{{
hl('@comment.note.comment', 'TODO', { bold = true })
hl('@operator', 'PUNCTUATION')
hl('@property', 'KEY')
hl('@punctuation', 'PUNCTUATION')
hl('@variable', 'VARIABLE')
hl('@variable.member', 'KEY')

-- lua {{{
hl('@constructor.lua', 'PUNCTUATION')
hl('@keyword.function.lua', 'KEYWORD')
hl('@keyword.lua', 'VARIABLE_TYPE')
hl('@keyword.repeat.lua', 'KEYWORD')
hl('@keyword.return.lua', 'KEYWORD')
-- }}}
-- yaml {{{
hl('@property.yaml', 'VARIABLE')
-- }}}
-- }}}

