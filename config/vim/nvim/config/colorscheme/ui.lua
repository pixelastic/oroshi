hl('Normal', 'GRAY_3') -- Normal text.
hl('NormalNC', 'none') -- Normal text in unfocused windows. Should not be set.

-- Tabs {{{
__.vars.tabline = {
  hl = { 
    fg = 'GRAY_4',
    bg = 'GRAY_8'
  }
}
hl('TabLineFill', 'GRAY_4', { bg = 'GRAY_8' }) --	Tab pages line, where there are no labels.
-- }}}

-- Splits {{{
hl('WinSeparator', 'YELLOW_9', { bg = 'BLACK', bold = true }) --	Separators between splits
hl('StatusLineNC', 'none', { bg = 'GRAY_8' }) --	Status lines of not-current windows.
-- }}}

-- Line Number {{{
hl('LineNr', 'GRAY') --	Line number column
hl('SignColumn', 'GRAY') --	Sign column
-- Signs
hl('GitSignsAdd', 'GREEN_9')
hl('GitSignsChange', 'PURPLE')
hl('GitSignsChangedelete', 'PURPLE')
hl('GitSignsTopdelete', 'RED_9')
hl('GitSignsDelete', 'RED_9')
hl('GitSignsUntracked', 'YYY')
-- Line numbers
hl('GitSignsAddNr', 'GREEN_9')
hl('GitSignsChangeNr', 'PURPLE')
hl('GitSignsChangedeleteNr', 'PURPLE')
hl('GitSignsTopdeleteNr', 'RED_9')
hl('GitSignsDeleteNr', 'RED_9')
hl('GitSignsUntrackedNr', 'XXX')
-- }}}

-- Current line {{{
hl('CursorLine', 'none', { bg = 'GRAY_9' }) --	Current line
hl('CursorLineNr', 'YELLOW', { bg = 'GRAY_9', bold = true }) --	Current line number
hl('CursorLineSign', 'none', { bg = 'GRAY_9'}) --	Current line sign
-- }}}

-- Statusline {{{
hl('StatusLine', 'GRAY_4', { bg = 'GRAY_8' }) --	Status line of current window.
-- }}}

-- Cursor {{{
vim.opt.guicursor = {
  "n:block-CursorModeNormal",
  "i:ver25-CursorModeInsert",
  "v:block-blinkon300-blinkoff300-CursorModeVisual",
  "t:block-CursorModeTerminal",  -- for example, in fzf search
  "c:hor25-CursorModeCommandNormal", -- Commandline & Search, when typing
  "ci:hor25-CursorModeCommandInsert", -- Commandline & Search, when editing

  -- Unused (yet) modes below
  "ve:block-CursorModeVisualExclusive",
  "o:block-CursorModeOperator",
  "r:block-CursorModeReplace",
  "cr:block-CursorModeCommandReplace",
  "sm:block-CursorModeShowMatch",
}
hl('CursorModeNormal', 'none', { bg = 'EMERALD' })
hl('CursorModeInsert', 'none', { bg = 'YELLOW_3' })
hl('CursorModeVisual', 'none', { bg = 'BLUE_7' })
hl('CursorModeTerminal', 'none', { bg = 'YELLOW' }) -- In fzf search
-- Commandline & Search, applied when entering commandline
__.vars.cursor = {
  hlDefault = { bg = 'TEAL' },
  hlSearch = { bg = 'ORANGE' }
}
-- hl('CursorModeCommandNormal', 'YYY')
-- hl('CursorModeCommandInsert', 'YYY')

-- Unused (yet) modes
hl('CursorModeVisualExclusive', 'XXX')
hl('CursorModeOperator', 'XXX')
hl('CursorModeReplace', 'XXX')
hl('CursorModeCommandReplace', 'XXX')
hl('CursorModeShowMatch', 'XXX')
-- }}}

-- Folds {{{
hl('Folded', 'none', { bg = 'GRAY_8'}) --	Closed fold
-- }}}

-- Visual mode {{{
hl('Visual', 'WHITE', { bg = 'BLUE', bold = true }) --		Visual mode selection.
-- }}}

-- Search mode {{{
hl('IncSearch', 'ORANGE_2', { bg = 'ORANGE_7', bold = true }) -- Match as I type
hl('CurSearch', 'ORANGE_2', { bg = 'ORANGE_7', bold = true }) --	Current selected match
hl('Search', 'ORANGE_9', { bg = 'ORANGE_3', bold = true }) -- All results
-- }}}

-- Completion (Ghost Text) {{{
hl('CmpGhostText', 'COMMENT') -- Ghost text
-- }}}

-- Completion {{{
hl('PmenuExtraSel', 'YYY') --	Popup menu: Selected item "extra text".
hl('PmenuExtra', 'YYY') --	Popup menu: Normal item "extra text".
hl('PmenuKindSel', 'YYY') --	Popup menu: Selected item "kind".
hl('PmenuKind', 'YYY') --	Popup menu: Normal item "kind".

__.vars.completion = {
  -- Regular completion menu
  hlVisible = {
    Pmenu =  { fg = 'NEUTRAL', bg = 'GRAY_8'}, -- Default
    PmenuSel = { fg = 'WHITE', bg = 'PURPLE', bold = true}, -- Selected line
    PmenuMatch = { fg = 'PURPLE'}, -- Match
    PmenuMatchSel = { fg = 'WHITE'}, -- Match on selected line
    PmenuSbar = { bg = 'GRAY_8' }, --	Scrollbar background
    PmenuThumb = { bg = 'GRAY_7' }, --	Scrollbar thumb
    CmpItemAbbr = { fg = 'COMMENT' },
    CmpItemAbbrMatch = { fg = 'PURPLE'}, -- Exact match
    CmpItemAbbrMatchFuzzy = { fg = 'PURPLE_LIGHT'}, -- Fuzzy match
    CmpItemKind = { fg = 'NEUTRAL'}, -- Type of result, on the right
  },
  -- Hidden completion menu, used for handling ghost text
  hlHidden = {
    Pmenu =  { fg='BLACK', bg = 'BLACK'},
    PmenuSel = { fg = 'BLACK'},
    CmpItemAbbr = { fg = 'BLACK' },
    CmpItemAbbrMatch = { fg = 'BLACK'},
    CmpItemAbbrMatchFuzzy = { fg = 'BLACK'}, 
    CmpItemKind = { fg = 'BLACK'},
  }
}
-- }}}

-- Statusline {{{
__.vars.statusline = {
  hlNormal = { bg = 'EMERALD_9', fg = 'EMERALD_2', bold = true },
  hlInsert = { bg = 'YELLOW', fg = 'BLACK', bold = true },
  hlVisual = { bg = 'BLUE', fg = 'WHITE', bold = true },
  hlSearch = { bg = 'ORANGE_7', fg = 'ORANGE_2', bold = true },
  hlCommand = { bg = 'TEAL', fg = 'TEAL_1', bold = true },
  hlUnknown = { bg = 'CYAN'},
  -- NvimTree
  hlNvimTreeIcon = { fg= 'YELLOW', bg = 'GREEN_9' },
  hlNvimTreeText = { fg= 'WHITE', bg = 'GREEN_9' },
  hlNvimTreeSeparator = { fg = 'GREEN_9' },
  -- Filepath
  hlFilepathDefault = { fg = 'GREEN', bold = true },
  hlFilepathReadonly = { fg = 'RED' },
  hlFilepathUnsavedChanges = { fg = 'VIOLET_4' },
  hlFilepathNoName = { fg = 'COMMENT' },
}
-- }}}

-- Commandline {{{
__.vars.commandline = {
  hlHidden = { fg = 'WHITE' }, -- Default highlight
  hlVisible = { fg = 'TEXT', bg = 'GRAY_8' },  -- When need to be more readable
}
hl('MsgSeparator', 'NONE', { bg = 'GRAY_6' }) --	Top bar separator of messsage
hl('MoreMsg', 'TEXT') -- Some additional text, like in <F3>
hl('ErrorMsg', 'RED_8') --	Error messages
hl('Question', 'COMMENT') --	"Press ENTER or type command to continue"
-- }}}

-- Notify {{{
hl('NotifyINFOBorder', 'YELLOW_7')
hl('NotifyINFOBody', 'YELLOW_6' )
-- }}}

-- Nvim Tree {{{
hl('NvimTreeClosedFolderIcon', 'YELLOW_6' )
hl('NvimTreeOpenedFolderIcon', 'YELLOW_6' )
hl('NvimTreeFolderArrowClosed', 'NEUTRAL' )
hl('NvimTreeFolderArrowOpen', 'NEUTRAL' )
hl('NvimTreeGitDirtyIcon', 'GIT_DIRTY' )
hl('NvimTreeRootFolder', 'DIRECTORY' )
hl('NvimTreeImageFile', 'YELLOW_6' )
-- }}}

-- Icons {{{
hl('DevIconCss', 'VIOLET' )
hl('DevIconEmbeddedOpenTypeFont', 'VIOLET' )
hl('DevIconFavicon', 'YELLOW_6' )
hl('DevIconJson', 'VIOLET' )
hl('DevIconJs', 'YELLOW' )
hl('DevIconPng', 'YELLOW_6' )
hl('DevIconReadme', 'AMBER' )
hl('DevIconSvg', 'VIOLET' )
hl('DevIconTrueTypeFont', 'VIOLET' )
hl('DevIconWebOpenFontFormat', 'VIOLET' )
hl('DevIconYml', 'VIOLET' )
-- }}}

-- GitSigns {{{
-- Lines (:Gitsigns toggle_linehl)
hl('GitSignsAddLn', 'none', { bg = 'GREEN_9'})
hl('GitSignsChangeLn', 'none', { bg = 'PURPLE_9' })
hl('GitSignsTopdeleteLn', 'none', { bg = 'RED_9' })
hl('GitSignsDeleteLn', 'none', { bg = 'RED_9' })
hl('GitSignsChangedeleteLn', 'XXX')
hl('GitSignsUntrackedLn', 'XXX')
-- }}}

-- Misc {{{
hl('ColorColumn', 'none', { bg = 'GRAY_9'}) --	Max column
hl('EndOfBuffer', 'BLACK') --	Filler lines (~) after the end of the buffer.
hl('NonText', 'GRAY_8') -- End-Of-Line (↲) and wrapped lines (↪) chars
hl('Whitespace', 'YELLOW') --	"nbsp", "space", "tab", "multispace", "lead" and "trail"
hl('MatchParen', 'WHITE', { bg = 'BLUE' }) -- Matching parenthesis
hl('Directory', 'DIRECTORY') --	Directory names 
-- }}}



