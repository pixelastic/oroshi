local hl = F.hl

hl('Normal', 'GRAY_3') -- Normal text.
hl('NormalNC', 'none') -- Normal text in unfocused windows. Should not be set.

-- Messages {{{
hl('DiagnosticInfo', 'INFO')
hl('ErrorMsg', 'RED_8', { bold = false}) --	Error messages
hl('Conceal', 'NEUTRAL') --	Hidden text
-- }}}

-- Tabs {{{
O.colors.tabline = {
  fg = 'GRAY_4',
  bg = 'GRAY_8'
}
hl('TabLineFill', 'GRAY_4', { bg = 'GRAY_8' }) --	Tab pages line, where there are no labels.
-- }}}

-- Splits {{{
hl('WinSeparator', 'YELLOW_9', { bg = 'BLACK', bold = true }) --	Separators between splits
hl('StatusLineNC', 'none', { bg = 'GRAY_8' }) --	Status lines of not-current windows.
-- }}}

-- Floating windows {{{
hl('WinBar', 'none', { bg = 'GRAY_8' } ) -- Window title
hl('WinBarNC', 'none', { bg = 'GRAY_8' }) -- Window title, unfocuses
hl('FloatBorder', 'GRAY_6', { bg = 'BLACK'})
hl('FloatTitle', 'YELLOW', { bg = 'GRAY_6'}) --	Title of floating windows.
hl('NormalFloat', 'GRAY_4', { bg = 'GRAY_8' }) --	Normal text in floating windows.
-- Noice input window
hl('NoiceCmdlinePopupBorderInput', 'GRAY_4')
hl('NoiceCmdlinePrompt', 'GRAY_4')
-- }}}

-- Line Number {{{
hl('LineNr', 'GRAY') --	Line number column
hl('SignColumn', 'GRAY') --	Sign column
-- LSP Diagnostics
hl('DiagnosticLineNrError', 'RED_2', { bg = 'RED_9'})
hl('DiagnosticLineNrWarn', 'YELLOW_5', { bg = 'YELLOW_9', bold = true })
hl('DiagnosticLineNrHint', 'YELLOW_5', { bg = 'YELLOW_9', bold = true })
hl('DiagnosticLineNrInfo', 'BLUE_5', { bg = 'BLUE_9' })
-- Git coloring
hl('GitSignsAddNr', 'GREEN_9')
hl('GitSignsChangeNr', 'PURPLE')
hl('GitSignsChangedeleteNr', 'PURPLE')
hl('GitSignsTopdeleteNr', 'RED_9')
hl('GitSignsDeleteNr', 'RED_9')
hl('GitSignsUntrackedNr', 'XXX')
-- }}}

-- Cursor {{{
vim.opt.guicursor = {}
F.setGuicursor('n',  'block',                        'CursorModeNormal')
F.setGuicursor('i',  'ver25',                        'CursorModeInsert')
F.setGuicursor("v",  "block-blinkon300-blinkoff300", "CursorModeVisual")
F.setGuicursor("t",  "block",                        "CursorModeTerminal")        -- for example, in fzf search
F.setGuicursor("c",  "hor25",                        "CursorModeCommandNormal")   -- Commandline & Search, when typing
F.setGuicursor("ci", "hor25",                        "CursorModeCommandInsert")   -- Commandline & Search, when editing
F.setGuicursor("ve", "block",                        "CursorModeVisualExclusive") -- UNUSED
F.setGuicursor("o",  "block",                        "CursorModeOperator")        -- UNUSED
F.setGuicursor("r",  "block",                        "CursorModeReplace")         -- UNUSED
F.setGuicursor("cr", "block",                        "CursorModeCommandReplace")  -- UNUSED
F.setGuicursor("sm", "block",                        "CursorModeShowMatch")       -- UNUSED

O.colors.cursor = {
  normal = { bg = 'EMERALD' },
  visual = { bg = 'BLUE_7' },
  insert = { bg = 'YELLOW_3' },
  command = { bg = 'TEAL' },
  search = { bg = 'ORANGE' },
  terminal = { bg = 'YELLOW' }, -- In fzf search
  ai = { bg = 'AMBER_7' },
}
hl('CursorModeInsert',        'none', O.colors.cursor.insert)
hl('CursorModeNormal',        'none', O.colors.cursor.normal)
hl('CursorModeVisual',        'none', O.colors.cursor.visual)
hl('CursorModeTerminal',      'none', O.colors.cursor.terminal)
hl('CursorModeCommandNormal', 'none', O.colors.cursor.command)
-- }}}

-- Current line {{{
hl('CursorLine', 'none', { bg = 'GRAY_9' }) --	Current line
hl('CursorLineNr', 'YELLOW', { bg = 'GRAY_9', bold = true }) --	Current line number
hl('CursorLineSign', 'none', { bg = 'GRAY_9'}) --	Current line sign
-- }}}

-- Statusline {{{
hl('StatusLine', 'GRAY_4', { bg = 'GRAY_8' }) --	Status line of current window.
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
-- Noice
hl('NoiceCmdlineIconSearch', 'BLACK', { bg = 'ORANGE_7' })
-- hl('NoiceCmdlinePopupBorderSearch', 'ORANGE_9')
-- }}}

-- Completion (Ghost Text) {{{
hl('CmpGhostText', 'COMMENT') -- Ghost text
-- }}}

-- Completion {{{
-- Noice completion, used when completing commandline
hl('NoicePopupmenu', 'NEUTRAL', { bg = 'GRAY_8' })    -- Default, swapped when selected
hl('NoicePopupmenuMatch', 'VIOLET')                   -- Matching letters, swapped when selected
hl('NoiceCompletionItemWord', 'NEUTRAL')              -- Words
hl('NoiceScrollbar', 'none', { bg = 'GRAY_8' })       -- Scrollbar background
hl('NoiceScrollbarThumb', 'NEUTRAL', { bg = 'none' }) -- Scrollbar thumb

-- O.colors.completion = {
--   -- Regular completion menu
--   visible = {
--     Pmenu =  { fg = 'NEUTRAL', bg = 'GRAY_8'}, -- Default
--     PmenuSel = { fg = 'WHITE', bg = 'PURPLE', bold = true}, -- Selected line
--     PmenuMatch = { fg = 'PURPLE'}, -- Match
--     PmenuMatchSel = { fg = 'WHITE'}, -- Match on selected line
--     PmenuSbar = { bg = 'GRAY_8' }, --	Scrollbar background
--     PmenuThumb = { bg = 'GRAY_7' }, --	Scrollbar thumb
--     CmpItemAbbr = { fg = 'COMMENT' },
--     CmpItemAbbrMatch = { fg = 'PURPLE'}, -- Exact match
--     CmpItemAbbrMatchFuzzy = { fg = 'PURPLE_LIGHT'}, -- Fuzzy match
--     CmpItemKind = { fg = 'NEUTRAL'}, -- Type of result, on the right
--   },
--   -- Hidden completion menu, used for handling ghost text
--   hidden = {
--     Pmenu =  { fg='BLACK', bg = 'BLACK'},
--     PmenuSel = { fg = 'BLACK'},
--     CmpItemAbbr = { fg = 'BLACK' },
--     CmpItemAbbrMatch = { fg = 'BLACK'},
--     CmpItemAbbrMatchFuzzy = { fg = 'BLACK'},
--     CmpItemKind = { fg = 'BLACK'},
--   }
-- }
-- }}}

-- Copilot {{{
hl('CopilotSuggestion', 'NEUTRAL', { bg = 'GRAY_8', italic = true, bold = true  })
-- }}}

-- Diagnostics {{{
-- Errors
hl('DiagnosticUnderlineError', 'RED_2', { bg = 'RED_9' }) -- Problematic code
hl('DiagnosticError', 'RED_2', { bg = 'RED_9', bold = true }) -- Floating text
hl('DiagnosticVirtualTextError', 'RED_3', { bg = 'RED_9' }) -- Virtual text
hl('DiagnosticDiagLineError', 'RED_2', { bg = 'RED_9'})

-- Warning
hl('DiagnosticUnderlineWarn', 'YELLOW_5', { bg = 'YELLOW_9' }) -- Problematic code
hl('DiagnosticWarn', 'YELLOW_5', { bg = 'YELLOW_9' }) -- Floating text
hl('DiagnosticVirtualTextWarn', 'YELLOW_5', { bg = 'YELLOW_9' }) -- Virtual text
hl('DiagnosticDiagLineWarn', 'YELLOW_5', { bg = 'YELLOW_9' }) -- Problematic code
-- Hints (considered as warnings)
hl('DiagnosticUnderlineHint', 'YELLOW_5', { bg = 'YELLOW_9' }) -- Problematic code
hl('DiagnosticHint', 'YELLOW_5', { bg = 'YELLOW_9' }) -- Floating text
hl('DiagnosticVirtualTextHint', 'YELLOW_5', { bg = 'YELLOW_9' }) -- Virtual text
hl('DiagnosticDiagLineHint', 'YELLOW_5', { bg = 'YELLOW_9' }) -- Problematic code
-- Unnecessary (considered as warnings)
hl('DiagnosticUnnecessary', 'YELLOW_5', { bg = 'YELLOW_9' }) -- Problematic code

-- Info
hl('DiagnosticUnderlineInfo', 'BLUE_3', { bg = 'BLUE_9'})   -- Problematic code
hl('DiagnosticInfo', 'BLUE', { bg = 'BLUE_9' })             -- Floating text
hl('DiagnosticVirtualTextInfo', 'BLUE_3', { bg = 'BLUE_9'}) -- Virtual text
hl('DiagnosticDiagLineInfo', 'BLUE_3', { bg = 'BLUE_9'})   -- Problematic code
-- }}}

-- Statusline {{{
O.colors.statusline = {
  normal = { bg = 'EMERALD_9', fg = 'EMERALD_2', bold = true },
  insert = { bg = 'YELLOW', fg = 'BLACK', bold = true },
  visual = { bg = 'BLUE', fg = 'WHITE', bold = true },
  search = { bg = 'ORANGE_7', fg = 'ORANGE_2', bold = true },
  command = { bg = 'TEAL', fg = 'TEAL_1', bold = true },
  unknown = { bg = 'CYAN'},
  -- NvimTree
  nvimTreeIcon = { fg= 'YELLOW', bg = 'GREEN_9' },
  nvimTreeText = { fg= 'WHITE', bg = 'GREEN_9' },
  nvimTreeSeparator = { fg = 'GREEN_9' },
  -- Filepath
  filepathDefault = { fg = 'GREEN', bold = true },
  filepathReadonly = { fg = 'RED' },
  filepathUnsavedChanges = { fg = 'VIOLET_4' },
  filepathNoName = { fg = 'COMMENT' },
  -- Copilot
  copilotNotLoaded = { bg = 'GRAY_7', fg = 'GRAY_8'},
  copilotDisabled = { bg = 'GRAY_7', fg = 'AMBER_9'},
  copilotEnabled = { bg = 'AMBER_7', fg = 'AMBER_1'},
  -- LSP
  lsp = {
    loading = { bg = 'GRAY_7', fg = 'GRAY_8' },
    ok = { bg = 'GREEN_9', fg = 'GREEN_2' },
    error = { bg = 'RED_9', fg = 'RED_2' }
  }
}
-- }}}

-- Commandline {{{
O.colors.commandline = {
  hidden = { fg = 'WHITE' }, -- Default highlight
  visible = { fg = 'TEXT', bg = 'GRAY_8' },  -- When need to be more readable
}
hl('NoiceCmdlineIconCmdline', 'BLACK', { bg = 'TEAL' }) -- Prefix
hl('NoiceCmdlineIconHelp', 'BLACK', { bg = 'BLUE' })    -- Prefix
hl('NoiceCmdlineIconLua', 'BLACK', { bg = 'VIOLET' })   -- Prefix
-- }}}

-- Lazy {{{
hl('LazyButtonActive', 'YELLOW', { bg = 'BLACK', bold = true })
hl('LazyButton', 'none', { bg = 'GRAY_9' })
hl('LazyCommit', 'GIT_COMMIT')
hl('LazyProp', 'ORANGE')
hl('LazyReasonEvent', 'ORANGE', { bold = false })
hl('LazyReasonFt', 'VIOLET')
hl('LazyReasonPlugin', 'YELLOW')
hl('LazyReasonSource', 'VIOLET')
hl('LazyReasonStart', 'GREEN')
hl('LazySpecial', 'PUNCTUATION')
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
hl('DevIconSvg', 'VIOLET')
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
-- }}}

-- Avante {{{
-- UI
hl('AvanteSidebarWinSeparator', 'GRAY_8', { bg = 'GRAY_8' }) -- Window seperators
-- Popups
hl('AvanteButtonDefault', 'WHITE', { bg = 'GRAY_7'})
hl('AvanteButtonDefaultHover', 'AMBER_1', { bg = 'AMBER_7', bold = true })
hl('AvanteConfirmTitle', 'AMBER_1', { bg = "AMBER_7", bold = true})
hl('AvanteCommentFg', 'NEUTRAL')
-- Response
hl('AvanteTitle', 'GRAY_8', { bg = 'GRAY_8' })                              -- Avante title
hl('AvanteReversedTitle', 'GRAY_8')                                          -- Avante title sides
hl('AvanteSidebarNormal', 'TEXT', { bg = 'GRAY_8'})                           -- Normal text
hl('AvanteStateSpinnerToolCalling', 'INFO')                                   -- name of the tool
hl('AvanteStateSpinnerGenerating', 'AMBER_7')             -- "generating"
hl('AvanteStateSpinnerSucceeded', 'GREEN_1', { bg = 'SUCCESS', bold = true }) -- "succeeded"
hl('AvanteStateSpinnerFailed', 'RED_1', { bg = 'RED_7', bold = true })
hl('AvanteTaskCompleted', 'SUCCESS', { bold = true })                         -- completed tag
hl('AvanteInlineHint', 'NEUTRAL')                                             -- Hint on output
-- Files
hl('AvanteSubtitle', 'AMBER_1', { bg = 'AMBER_7'}) -- File title
hl('AvanteReversedSubtitle', 'AMBER_7')
-- Prompt
hl('AvanteThirdTitle', 'AMBER_7', { bg = 'AMBER_7' })                  -- Chat title
hl('AvanteReversedThirdTitle', 'AMBER_7')
hl('AvanteSidebarWinHorizontalSeparator', 'AMBER_7', { bg = 'GRAY_8'}) -- Manual separator
hl('AvantePromptInput', 'TEXT')
hl('AvantePromptInputBorder', 'none', { bg = 'GRAY_6'})
hl('AvantePopupHint', 'GRAY_8', { bg = 'GRAY_8', blend = 100 })        -- Tokens: 3482, etc in chat window
-- hl('Visual', 'WHITE', { bg = 'BLUE', bold = true }) -- Used for keycaps
-- Code
hl('AvanteConflictIncoming', 'none', { bg = 'GREEN_9'})
hl('AvanteConflictCurrentLabel', 'RED_5', { bg = 'RED_9', bold = true })
hl('AvanteConflictIncomingLabel', 'GREEN_6', { bg = 'GREEN_8', bold = true})
hl('AvanteToBeDeletedWOStrikethrough', 'none', { bg = 'RED_9', strikethrough = true })
--
--
-- }}}

-- Noice {{{
hl('NoiceMini', 'none')
-- O_message
hl('NoiceOMessageNormal', 'NOTICE')
-- O_warning
hl('NoiceOWarningNormal', 'WARNING')
-- O_error
hl('NoiceFormatLevelError', 'RED_2', { bg = 'RED_9', bold = true })
hl('NoiceOErrorErrorMsg', 'RED_8')
-- Messages
hl('NoiceSplit', 'none', { bg = 'BLACK'})
hl('MoreMsg', 'COMMENT')
-- }}}

-- Notify {{{
hl('NotifyBackground', 'none', { bg = 'BLACK'})

hl('NotifyDEBUGBody', 'NOTICE')
hl('NotifyDEBUGBorder', 'NOTICE')
hl('NotifyDEBUGIcon', 'NOTICE')
hl('NotifyDEBUGTitle', 'NOTICE')
hl('NoiceFormatLevelDebug', 'NOTICE')
hl('NoiceODebugNormal', 'NOTICE')

hl('NotifyTRACEBody', 'TEXT')
hl('NotifyTRACEBorder', 'TEXT')
hl('NotifyTRACEIcon', 'TEXT')
hl('NotifyTRACETitle', 'TEXT')

hl('NotifyINFOIcon', 'INFO')
hl('NotifyINFOTitle', 'INFO')
hl('NotifyINFOBorder', 'INFO')
hl('NotifyINFOBody', 'INFO' )

hl('NotifyWARNBody', 'WARNING')
hl('NotifyWARNBorder', 'WARNING')
hl('NotifyWARNIcon', 'WARNING')
hl('NotifyWARNTitle', 'WARNING')

hl('NotifyERRORBody', 'ERROR')
hl('NotifyERRORBorder', 'ERROR')
hl('NotifyERRORIcon', 'ERROR')
hl('NotifyERRORTitle', 'ERROR')
-- }}}


-- Misc {{{
hl('ColorColumn', 'none', { bg = 'GRAY_9'}) -- Max column
hl('EndOfBuffer', 'BLACK')                  -- Filler lines (~) after the end of the buffer.
hl('NonText', 'GRAY_8')                     -- End-Of-Line (↲) and wrapped lines (↪) chars
hl('Whitespace', 'YELLOW')                  -- "nbsp", "space", "tab", "multispace", "lead" and "trail"
hl('MatchParen', 'WHITE', { bg = 'BLUE' })  -- Matching parenthesis
hl('Directory', 'DIRECTORY')                -- Directory names 
-- }}}



