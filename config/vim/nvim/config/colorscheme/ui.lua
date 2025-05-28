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

-- Line Number {{{
hl('LineNr', 'GRAY') --	Line number column
hl('SignColumn', 'GRAY') --	Sign column
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

-- Commandline {{{
__.vars.commandline = {
  hlDefault = { fg = 'WHITE' }, -- Default highlight
  hlReadable = { fg = 'TEXT', bg = 'GRAY_8' },  -- When need to be more readable
}
hl('MsgSeparator', 'NONE', { bg = 'GRAY_6' }) --	Top bar separator of messsage
hl('MoreMsg', 'TEXT') -- Some additional text, like in <F3>
hl('ErrorMsg', 'RED_8') --	Error messages
hl('Question', 'COMMENT') --	"Press ENTER or type command to continue"
-- }}}

-- Splits {{{
hl('WinSeparator', 'YELLOW_9', { bg = 'BLACK', bold = true }) --	Separators between splits
hl('StatusLineNC', 'none', { bg = 'GRAY_8' }) --	Status lines of not-current windows.
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

-- Misc {{{
hl('Directory', 'DIRECTORY') --	Directory names 
-- }}}

