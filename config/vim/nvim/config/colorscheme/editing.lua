-- Misc {{{
hl('ColorColumn', 'none', { bg = 'GRAY_9'}) --	Max column
hl('EndOfBuffer', 'BLACK') --	Filler lines (~) after the end of the buffer.
hl('NonText', 'GRAY_8') -- End-Of-Line (↲) and wrapped lines (↪) chars
hl('Whitespace', 'YELLOW') --	"nbsp", "space", "tab", "multispace", "lead" and "trail"
hl('MatchParen', 'WHITE', { bg = 'BLUE' }) -- Matching parenthesis
-- }}}


-- Folds {{{
hl('Folded', 'none', { bg = 'GRAY_8'}) --	Closed fold
-- }}}

-- Current line {{{
hl('CursorLine', 'none', { bg = 'GRAY_9' }) --	Current line
hl('CursorLineNr', 'YELLOW', { bg = 'GRAY_9', bold = true }) --	Current line number
hl('CursorLineSign', 'none', { bg = 'GRAY_9'}) --	Current line sign
-- }}}

-- Cursor {{{
vim.opt.guicursor = {
  "n:block-CursorModeNormal",
  "i:ver25-CursorModeInsert",
  "v:block-blinkon300-blinkoff300-CursorModeVisual",
  "c:hor25-CursorModeCommandNormal",

  -- Unused (yet) modes below
  "ve:block-CursorModeVisualExclusive",
  "o:block-CursorModeOperator",
  "r:block-CursorModeReplace",
  "ci:block-CursorModeCommandInsert",
  "cr:block-CursorModeCommandReplace",
  "sm:block-CursorModeShowMatch",
  "t:block-CursorModeTerminal",
}
hl('CursorModeNormal', 'none', { bg = 'EMERALD' })
hl('CursorModeInsert', 'none', { bg = 'YELLOW_3' })
hl('CursorModeVisual', 'none', { bg = 'BLUE_7' })
hl('CursorModeCommandNormal', 'none', { bg = 'TEAL' })
-- Unused (yet) modes
hl('CursorModeVisualExclusive', 'YYY')
hl('CursorModeOperator', 'YYY')
hl('CursorModeReplace', 'YYY')
hl('CursorModeCommandInsert', 'YYY')
hl('CursorModeCommandReplace', 'YYY')
hl('CursorModeShowMatch', 'YYY')
hl('CursorModeTerminal', 'YYY')
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

-- Completion (Fake hidden menu)
-- Fake Wildmenu, displayed hidden above statusbar,
hl('Pmenu', 'BLACK', { bg = 'BLACK'})       -- Fake Wildmenu Background
hl('CmpItemAbbr', 'BLACK') -- Suggestions
hl('PmenuSel', 'BLACK') -- Current selection
hl('CmpItemAbbrMatch', 'BLACK') -- Partial match
hl('CmpItemAbbrMatchFuzzy', 'BLACK') -- Fuzzy match
-- }}}
