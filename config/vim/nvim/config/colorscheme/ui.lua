local hl = F.hl

hl('Normal', 'GRAY_3') -- Normal text.
hl('NormalNC', 'none') -- Normal text in unfocused windows. Should not be set.

-- Misc {{{
hl('ColorColumn', 'none', { bg = 'GRAY_9'}) -- Max column
hl('EndOfBuffer', 'BLACK')                  -- Filler lines (~) after the end of the buffer.
hl('NonText', 'GRAY_8')                     -- End-Of-Line (↲) and wrapped lines (↪) chars
hl('Whitespace', 'YELLOW')                  -- "nbsp", "space", "tab", "multispace", "lead" and "trail"
hl('MatchParen', 'WHITE', { bg = 'BLUE' })  -- Matching parenthesis
hl('Directory', 'DIRECTORY')                -- Directory names
-- }}}

-- Messages {{{
hl('DiagnosticInfo', 'INFO')
hl('ErrorMsg', 'RED_8', { bold = false}) --	Error messages
hl('Conceal', 'NEUTRAL') --	Hidden text
hl('Question', 'NEUTRAL') --	"Press ENTER or type command to continue"
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
-- Git coloring
hl('GitSignsAddNr', 'GREEN_9')
hl('GitSignsChangeNr', 'PURPLE')
hl('GitSignsChangedeleteNr', 'PURPLE')
hl('GitSignsTopdeleteNr', 'RED_9')
hl('GitSignsDeleteNr', 'RED_9')
hl('GitSignsUntrackedNr', 'XXX')
-- Current line
hl('CursorLineNr', 'YELLOW', { bg = 'GRAY_9', bold = true }) --	Current line number
hl('CursorLineSign', 'none', { bg = 'GRAY_9'}) --	Current line sign
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
-- }}}

-- Folds {{{
hl('Folded', 'none', { bg = 'GRAY_8'}) --	Closed fold
hl('FoldColumn', 'GRAY') -- Column for fold symbol
hl('CursorLineFold', 'none', { bg = 'GRAY_9' }) -- Column for fold symbol on active line
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
hl('DiagnosticLineNrError', 'RED_2', { bg = 'RED_9'})                        -- Line number
hl('DiagnosticUnderlineError', 'none', { undercurl = true, sp = 'RED' })     -- Problematic code
hl('DiagnosticError', 'RED_2', { bg = 'RED_9', bold = true })                -- Floating text
hl('DiagnosticVirtualTextError', 'RED_3', { bg = 'RED_9' })                  -- Virtual text
hl('DiagnosticDiagLineError', 'RED_2', { bg = 'RED_9'})                      -- Diag line

-- Warning
hl('DiagnosticLineNrWarn', 'YELLOW_5', { bg = 'YELLOW_9', bold = true })             -- Line number
hl('DiagnosticUnderlineWarn', 'none', { undercurl = true, sp = 'YELLOW_6' })           -- Problematic code
hl('DiagnosticUnnecessary', 'none', { undercurl = true, sp = 'YELLOW_6' })             -- Problematic code
hl('DiagnosticWarn', 'YELLOW_5', { bg = 'YELLOW_9' })                                -- Floating text
hl('DiagnosticVirtualTextWarn', 'YELLOW_5', { bg = 'YELLOW_9' })                     -- Virtual text
hl('DiagnosticDiagLineWarn', 'YELLOW_5', { bg = 'YELLOW_9' })                        -- Diag line

-- Info
hl('DiagnosticLineNrInfo', 'BLUE_5', { bg = 'BLUE_9' })     -- Line number
hl('DiagnosticUnderlineInfo', 'none', { undercurl = true, sp = 'BLUE_9' })           -- Problematic code
hl('DiagnosticInfo', 'BLUE', { bg = 'BLUE_9' })             -- Floating text
hl('DiagnosticVirtualTextInfo', 'BLUE_3', { bg = 'BLUE_9'}) -- Virtual text
hl('DiagnosticDiagLineInfo', 'BLUE_3', { bg = 'BLUE_9'})    -- Diag line

-- Hints
hl('DiagnosticLineNrHint', 'VIOLET_5', { bg = 'GRAY_7' })      -- Line number
hl('DiagnosticUnderlineHint', 'none', { undercurl = true, sp = 'VIOLET_7' })           -- Problematic code
hl('DiagnosticHint', 'VIOLET_5', { bg = 'GRAY_8' })            -- Floating text
hl('DiagnosticVirtualTextHint', 'VIOLET_5', { bg = 'GRAY_8' }) -- Virtual text
hl('DiagnosticDiagLineHint', 'VIOLET_4', { bg = 'GRAY_8' })    -- Diag line
-- }}}

-- Diff {{{
hl('DiffAdd', 'none', { bg = 'DARK_GREEN', ctermfg = 'WHITE' }) -- Added lines
hl('DiffChange', 'none', { bg = 'DARK_GREEN' }) -- Changed lines
hl('DiffText', 'none', { bg = 'DARK_PURPLE'}) -- Changed text specifically
-- }}}

-- Statusline {{{
hl('StatusLine', 'GRAY_4', { bg = 'GRAY_8' }) --	Status line of current window.
O.colors.statusline = {
  normal = { bg = 'EMERALD_9', fg = 'EMERALD_2', bold = true },
  insert = { bg = 'YELLOW', fg = 'BLACK', bold = true },
  visual = { bg = 'BLUE', fg = 'WHITE', bold = true },
  search = { bg = 'ORANGE_7', fg = 'ORANGE_2', bold = true },
  command = { bg = 'TEAL', fg = 'TEAL_1', bold = true },
  unknown = { bg = 'CYAN'},
  -- Filepath
  filepathDefault = { fg = 'GREEN', bold = true },
  filepathReadonly = { fg = 'RED' },
  filepathUnsavedChanges = { fg = 'VIOLET_4' },
  filepathNoName = { fg = 'COMMENT' },
  -- NvimTree
  nvimTreeIcon = { fg= 'YELLOW', bg = 'GREEN_9' },
  nvimTreeText = { fg= 'WHITE', bg = 'GREEN_9' },
  nvimTreeSeparator = { fg = 'GREEN_9' },
  healthcheck = { bg = "RED_LIGHT", fg = "WHITE" },  -- Healthcheck
  codecompanion = { bg = 'AMBER_7', fg = 'AMBER_1'}, -- CodeCompanion
  fileencoding = { bg= 'RED_9', fg = 'RED_2' },      -- Fileencoding
  macro = { fg = 'RED', bg = 'DARK_RED' },           -- Macro
  filetype = { bg = 'GRAY_9', fg = 'WHITE' },        -- Filetype
  -- LSP
  lsp = {
    off = { fg = 'GRAY_8', bg = 'DARK_BLUE' },
    loading = { fg = 'BLUE_9', bg = 'DARK_BLUE' },

    error = { fg = 'RED_2', bg = 'RED_9' },
    warning = { fg = 'YELLOW_5',  bg = 'YELLOW_9' },
    info = { fg = 'BLUE_3', bg = 'BLUE_9' },
    hint = { fg = 'VIOLET_5', bg = 'GRAY_7' },
    success = { fg = 'GREEN_2', bg = 'GREEN_9'  },
  },
  -- Copilot
  copilotNotLoaded = { fg = 'GRAY_8', bg = 'DARK_AMBER' },
  copilotEnabled = { fg = 'AMBER_1', bg = 'AMBER_7' },
  copilotDisabled = { fg = 'AMBER_9', bg = 'DARK_AMBER' },
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

-- Noice {{{
hl('NoiceMini', 'none')
-- Error
hl('NoiceFormatLevelError', 'RED_2', { bg = 'RED_9', bold = true })
hl('NoiceOErrorErrorMsg', 'RED_8')
-- Warn
hl('NoiceOWarningMessage', 'YELLOW')
hl('NoiceOWarningIconSeparator', 'YELLOW_9', { bg = 'BLACK'})
hl('NoiceOWarningIcon', 'YELLOW_5', { bg = 'YELLOW_9', bold = true })
-- Info
hl('NoiceOInfoMessage', 'BLUE')
hl('NoiceOInfoIconSeparator', 'BLUE_9', { bg = 'BLACK'})
hl('NoiceOInfoIcon', 'BLUE_3', { bg = 'BLUE_9', bold = true })
hl('NoiceFormatLevelInfo', 'BLUE')
-- Debug
hl('NoiceODebugMessage', 'VIOLET')
-- Messages
hl('NoiceSplit', 'none', { bg = 'BLACK'})
hl('MoreMsg', 'COMMENT')
hl('NoiceFormatDate', 'DATE')
hl('NoiceOMessageNormal', 'NOTICE')
hl('NoiceFormatEvent', 'PURPLE_4')
hl('NoiceFormatKind', 'PURPLE_3')
-- :Noice all
hl('NoiceOMessageSeparator', 'GRAY')
hl('NoiceOMessageEvent', 'PURPLE_4')
hl('NoiceOMessageKind', 'PURPLE_3')
hl('NoiceOMessageCmdline', 'TEAL')
hl('NoiceOMessagePrefix', 'GRAY')
hl('NoiceOMessageMessage', 'GRAY')
-- }}}

-- CodeCompanion {{{
O.colors.codecompanion = {
  default = {
    chatNormal  = { fg = 'none', bg = 'GRAY_8' },
    chatBorder  = { fg = 'DARK_AMBER', bg = 'BLACK' },
  },
  thinking = {
    chatNormal  = { fg = 'none', bg = 'DARK_AMBER' },
    chatBorder  = { fg = 'AMBER_7', bg = 'BLACK' },
  }
}
hl("CodeCompanionChatTitle", 'AMBER_1', { bg = 'AMBER_7' })
hl("CodeCompanionChatTitleDecoration", 'AMBER_7')
hl("CodeCompanionChatBorder", 'none', O.colors.codecompanion.default.chatBorder)
hl("CodeCompanionChatNormal", 'none', O.colors.codecompanion.default.chatNormal)
hl("CodeCompanionChatInnerTitle", 'AMBER_5', { bold = true }) -- ## Headers
hl("CodeCompanionChatVariable", 'VARIABLE', { bold = true })
hl("CodeCompanionChatEndOfBuffer", 'GRAY_8')

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
