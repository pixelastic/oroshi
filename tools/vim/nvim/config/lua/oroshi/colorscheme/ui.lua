local hl = F.hl

hl("Normal", "gray-3") -- Normal text.
hl("NormalNC", "none") -- Normal text in unfocused windows. Should not be set.

-- Misc {{{
hl("ColorColumn", "none", { bg = "gray-9" }) -- Max column
hl("EndOfBuffer", "black") -- Filler lines (~) after the end of the buffer.
hl("NonText", "gray-8") -- End-Of-Line (↲) and wrapped lines (↪) chars
hl("Whitespace", "yellow") -- "nbsp", "space", "tab", "multispace", "lead" and "trail"
hl("MatchParen", "emerald", { bg = "emerald-8" }) -- Matching parenthesis
hl("Directory", "directory") -- Directory names
-- }}}

-- Messages {{{
hl("MsgSeparator", "none", { bg = "neutral" }) --	Top bar separator of messsage
hl("DiagnosticInfo", "info")
hl("ErrorMsg", "red-7", { bold = false }) --	Error messages
hl("Conceal", "neutral") --	Hidden text
hl("Question", "neutral") --	"Press ENTER or type command to continue"
hl("WarningMsg", "warning") --	Warning messages.
-- }}}

-- Tabs {{{
O.colors.tabline = {
  fg = "gray-4",
  bg = "gray-8",
}
hl("TabLineFill", "gray-4", { bg = "gray-8" }) --	Tab pages line, where there are no labels.
-- }}}

-- Splits {{{
hl("WinSeparator", "yellow-8", { bg = "black", bold = true }) --	Separators between splits
hl("StatusLineNC", "none", { bg = "gray-8" }) --	Status lines of not-current windows.
-- }}}

-- Floating windows {{{
hl("WinBar", "none", { bg = "gray-8" }) -- Window title
hl("WinBarNC", "none", { bg = "gray-8" }) -- Window title, unfocuses
hl("FloatBorder", "gray-6", { bg = "black" })
hl("FloatTitle", "yellow", { bg = "gray-6" }) --	Title of floating windows.
hl("NormalFloat", "gray-4", { bg = "gray-8" }) --	Normal text in floating windows.
-- Noice input window
hl("NoiceCmdlinePopupBorderInput", "gray-4")
hl("NoiceCmdlinePrompt", "gray-4")
hl("NoiceCmdlineIcon", "gray-4")
-- Noice Yes/No confirm
hl("NoiceConfirm", "cyan", { bg = "green-0" })
hl("NoiceConfirmBorder", "green", { bg = "green-0" })
hl("NoiceFormatConfirm", "green")
hl("NoiceFormatConfirmDefault", "red", { bg = "red-0" })
-- }}}

-- Line Number {{{
hl("LineNr", "gray") --	Line number column
hl("SignColumn", "gray") --	Sign column
-- Git coloring
hl("GitSignsAddNr", "green-9", { bg = "green-0" })
hl("GitSignsChangeNr", "purple", { bg = "purple-0" })
hl("GitSignsChangedeleteNr", "purple", { bg = "purple-0" })
hl("GitSignsTopdeleteNr", "red-8", { bg = "red-0" })
hl("GitSignsDeleteNr", "red-8", { bg = "red-0" })
hl("GitSignsUntrackedNr", "XXX")
-- Current line
hl("CursorLineNr", "yellow", { bg = "gray-9", bold = true }) --	Current line number
hl("CursorLineSign", "none", { bg = "gray-9" }) --	Current line sign
-- }}}

-- Cursor {{{
vim.opt.guicursor = {}
F.setGuicursor("n", "block", "CursorModeNormal")
F.setGuicursor("i", "ver25", "CursorModeInsert")
F.setGuicursor("v", "block-blinkon300-blinkoff300", "CursorModeVisual")
F.setGuicursor("t", "block", "CursorModeTerminal") -- for example, in fzf search
F.setGuicursor("c", "hor25", "CursorModeCommandNormal") -- Commandline & Search, when typing
F.setGuicursor("ci", "hor25", "CursorModeCommandInsert") -- Commandline & Search, when editing
F.setGuicursor("ve", "block", "CursorModeVisualExclusive") -- UNUSED
F.setGuicursor("o", "block", "CursorModeOperator") -- UNUSED
F.setGuicursor("r", "block", "CursorModeReplace") -- UNUSED
F.setGuicursor("cr", "block", "CursorModeCommandReplace") -- UNUSED
F.setGuicursor("sm", "block", "CursorModeShowMatch") -- UNUSED

O.colors.cursor = {
  insert = { bg = "yellow-2" },
  normal = { bg = "emerald" },
  visual = { bg = "blue-6" },
  terminal = { bg = "yellow" }, -- In fzf search
  command = { bg = "teal" },
  search = { bg = "orange" },
  ai = { bg = "amber-6" },
}
hl("CursorModeInsert", "none", O.colors.cursor.insert)
hl("CursorModeNormal", "none", O.colors.cursor.normal)
hl("CursorModeVisual", "none", O.colors.cursor.visual)
hl("CursorModeTerminal", "none", O.colors.cursor.terminal)
hl("CursorModeCommandNormal", "none", O.colors.cursor.command)
-- }}}

-- Current line {{{
hl("CursorLine", "none", { bg = "gray-9" }) --	Current line
-- }}}

-- Folds {{{
hl("Folded", "none", { bg = "gray-8" }) --	Closed fold
hl("FoldColumn", "gray") -- Column for fold symbol
hl("CursorLineFold", "none", { bg = "gray-9" }) -- Column for fold symbol on active line
hl("FoldDebugMarker", "violet-8", { bg = "violet-0" }) -- Marker column in fold debug
hl("FoldDebugLevel1", "purple", { bg = "purple-0" }) -- Level 1 in fold debug
hl("FoldDebugLevel2", "blue", { bg = "blue-0" }) -- Level 2 in fold debug
hl("FoldDebugLevel3", "green", { bg = "green-0" }) -- Level 3 in fold debug
hl("FoldDebugLevel4", "yellow", { bg = "yellow-0" }) -- Level 4 in fold debug
hl("FoldDebugLevel5", "orange", { bg = "orange-0" }) -- Level 5 in fold debug
hl("FoldDebugLevel6", "red", { bg = "red-0" }) -- Level 6 in fold debug
-- }}}

-- Visual mode {{{
hl("Visual", "white", { bg = "blue", bold = true }) --		Visual mode selection.
-- }}}

-- Search mode {{{
hl("IncSearch", "orange-1", { bg = "orange-6", bold = true }) -- Match as I type
hl("CurSearch", "orange-1", { bg = "orange-6", bold = true }) -- Current selected match
hl("Search", "orange-8", { bg = "orange-2", bold = true }) -- All results
hl("Substitute", "orange-8", { bg = "orange-2", bold = true }) -- Replace as I type
-- Noice
hl("NoiceCmdlinePopupBorderSearch", "orange-6")
hl("NoiceCmdlineIconSearch", "orange-6", { bg = "none" })
-- }}}

-- Completion (Ghost Text) {{{
hl("CmpGhostText", "comment") -- Ghost text
hl("ComplMatchIns", "none") --	Text that just got completed
-- }}}

-- Completion {{{
-- Noice completion, used when completing commandline
hl("NoicePopupmenu", "neutral", { bg = "gray-8" }) -- Default, swapped when selected
hl("NoicePopupmenuMatch", "violet") -- Matching letters, swapped when selected
hl("NoiceCompletionItemWord", "neutral") -- Words
hl("NoiceScrollbar", "none", { bg = "gray-8" }) -- Scrollbar background
hl("NoiceScrollbarThumb", "neutral", { bg = "none" }) -- Scrollbar thumb

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
hl("CopilotSuggestion", "neutral", { bg = "gray-8", italic = true, bold = true })
-- }}}

-- Diagnostics {{{
-- Errors
hl("DiagnosticLineNrError", "red-1", { bg = "red-8" }) -- Line number
hl("DiagnosticUnderlineError", "none", { undercurl = true, sp = "red" }) -- Problematic code
hl("DiagnosticError", "red-1", { bg = "red-8", bold = true }) -- Floating text
hl("DiagnosticVirtualTextError", "red-2", { bg = "red-8" }) -- Virtual text
hl("DiagnosticDiagLineError", "red-1", { bg = "red-8" }) -- Diag line

-- Warning
hl("DiagnosticLineNrWarn", "yellow-4", { bg = "yellow-8", bold = true }) -- Line number
hl("DiagnosticUnderlineWarn", "none", { undercurl = true, sp = "yellow-5" }) -- Problematic code
hl("DiagnosticUnnecessary", "none", { undercurl = true, sp = "yellow-5" }) -- Problematic code
hl("DiagnosticWarn", "yellow-4", { bg = "yellow-8" }) -- Floating text
hl("DiagnosticVirtualTextWarn", "yellow-4", { bg = "yellow-8" }) -- Virtual text
hl("DiagnosticDiagLineWarn", "yellow-4", { bg = "yellow-8" }) -- Diag line
hl("DiagnosticDeprecated", "yellow-4", { bg = "yellow-0", undercurl = true }) -- Deprecated

-- Info
hl("DiagnosticLineNrInfo", "blue-4", { bg = "blue-8" }) -- Line number
hl("DiagnosticUnderlineInfo", "none", { undercurl = true, sp = "blue-8" }) -- Problematic code
hl("DiagnosticInfo", "blue", { bg = "blue-8" }) -- Floating text
hl("DiagnosticVirtualTextInfo", "blue-2", { bg = "blue-8" }) -- Virtual text
hl("DiagnosticDiagLineInfo", "blue-2", { bg = "blue-8" }) -- Diag line

-- Hints
hl("DiagnosticLineNrHint", "violet-4", { bg = "gray-7" }) -- Line number
hl("DiagnosticUnderlineHint", "none", { undercurl = true, sp = "violet-6" }) -- Problematic code
hl("DiagnosticHint", "violet-4", { bg = "gray-8" }) -- Floating text
hl("DiagnosticVirtualTextHint", "violet-4", { bg = "gray-8" }) -- Virtual text
hl("DiagnosticDiagLineHint", "violet-3", { bg = "gray-8" }) -- Diag line
-- }}}

-- Spellchecker {{{
hl("SpellBad", "red", { underline = true })
hl("SpellCap", "red", { underline = true })
-- }}}

-- Diff {{{
hl("DiffAdd", "none", { bg = "green-0", ctermfg = "white" }) -- Added lines
hl("DiffChange", "none", { bg = "green-0" }) -- Changed lines
hl("DiffText", "none", { bg = "purple-0" }) -- Changed text specifically
-- }}}

-- Statusline {{{
hl("StatusLine", "gray-4", { bg = "gray-8" }) --	Status line of current window.
O.colors.statusline = {
  normal = { bg = "emerald-8", fg = "emerald-1", bold = true },
  insert = { bg = "yellow", fg = "black", bold = true },
  visual = { bg = "blue", fg = "white", bold = true },
  search = { bg = "orange-6", fg = "orange-1", bold = true },
  command = { bg = "teal", fg = "teal-1", bold = true },
  unknown = { bg = "cyan" },
  -- Context badge
  worktreeBadge = { bg = "orange-6", fg = "orange-1" },
  -- Filepath
  filepathDefault = { fg = "gray-4" },
  filepathReadonly = { fg = "red" },
  filepathUnsavedChanges = { fg = "git-modified" },
  filepathNoName = { fg = "comment" },
  -- NvimTree
  nvimTreeIcon = { fg = "yellow", bg = "green-9" },
  nvimTreeText = { fg = "white", bg = "green-9" },
  nvimTreeSeparator = { fg = "green-9" },
  -- Special
  healthcheck = { bg = "red-3", fg = "white" },
  ai = { bg = "amber-6", fg = "amber-1" },
  kitty = { bg = "blue", fg = "white", bold = true },
  -- Right side
  fileencoding = { bg = "red-8", fg = "red-1" },
  macro = { fg = "red", bg = "red-0" },
  filetype = { bg = "gray-9", fg = "white" },
  -- LSP
  lsp = {
    off = { fg = "gray-8", bg = "blue-0" },
    loading = { fg = "blue-8", bg = "blue-0" },

    error = { fg = "red-1", bg = "red-8" },
    warning = { fg = "yellow-4", bg = "yellow-8" },
    info = { fg = "blue-2", bg = "blue-8" },
    hint = { fg = "violet-4", bg = "gray-7" },
    success = { fg = "green-2", bg = "green-9" },
  },
  -- Copilot
  copilotNotLoaded = { fg = "gray-8", bg = "amber-0" },
  copilotEnabled = { fg = "amber-1", bg = "amber-6" },
  copilotDisabled = { fg = "amber-8", bg = "amber-0" },
}
-- }}}

-- Commandline {{{
O.colors.commandline = {
  hidden = { fg = "white" }, -- Default highlight
  visible = { fg = "text", bg = "gray-8" }, -- When need to be more readable
}
hl("NoiceCmdlinePopup", "none", { bg = "gray-9" })
-- Vim Cmdline {{{
hl("NoiceCmdlinePopupBorderCmdline", "teal")
hl("NoiceCmdlineIconCmdline", "teal", { bg = "none" })
-- }}}
-- Shell {{{
hl("NoiceCmdlinePopupBorderFilter", "green")
hl("NoiceCmdlineIconFilter", "green", { bg = "none" })
-- }}}
-- Lua {{{
hl("NoiceCmdlinePopupBorderLua", "violet")
hl("NoiceCmdlineIconLua", "violet", { bg = "none" }) -- Prefix
-- }}}
-- Help {{{
hl("NoiceCmdlinePopupBorderHelp", "blue")
hl("NoiceCmdlineIconHelp", "blue", { bg = "none" })
-- }}}

-- }}}

-- Noice {{{
hl("NoiceMini", "none")
-- Error
hl("NoiceFormatLevelError", "red-1", { bg = "red-8", bold = true })
hl("NoiceOErrorErrorMsg", "red-7")
-- Warn
hl("NoiceOWarningMessage", "yellow")
hl("NoiceOWarningIconSeparator", "yellow-8", { bg = "black" })
hl("NoiceOWarningIcon", "yellow-4", { bg = "yellow-8", bold = true })
-- Info
hl("NoiceOInfoMessage", "blue")
hl("NoiceOInfoIconSeparator", "blue-8", { bg = "black" })
hl("NoiceOInfoIcon", "blue-2", { bg = "blue-8", bold = true })
hl("NoiceFormatLevelInfo", "blue")
-- Debug
hl("NoiceODebugMessage", "violet")
-- Messages
hl("NoiceSplit", "none", { bg = "black" })
hl("MoreMsg", "comment")
hl("NoiceFormatDate", "date")
hl("NoiceOMessageNormal", "notice")
hl("NoiceFormatEvent", "purple-3")
hl("NoiceFormatKind", "purple-2")
-- :Noice all
hl("NoiceOMessageSeparator", "gray")
hl("NoiceOMessageEvent", "purple-3")
hl("NoiceOMessageKind", "purple-2")
hl("NoiceOMessageCmdline", "teal")
hl("NoiceOMessagePrefix", "gray")
hl("NoiceOMessageMessage", "gray")
-- }}}

-- CodeCompanion {{{
O.colors.codecompanion = {
  default = {
    chatNormal = { fg = "none", bg = "gray-8" },
    chatBorder = { fg = "amber-0", bg = "black" },
  },
  thinking = {
    chatNormal = { fg = "none", bg = "amber-0" },
    chatBorder = { fg = "amber-6", bg = "black" },
  },
}
hl("CodeCompanionChatTitle", "amber-1", { bg = "amber-6" })
hl("CodeCompanionChatTitleDecoration", "amber-6")
hl("CodeCompanionChatBorder", "none", O.colors.codecompanion.default.chatBorder)
hl("CodeCompanionChatNormal", "none", O.colors.codecompanion.default.chatNormal)
hl("CodeCompanionChatInnerTitle", "amber-4", { bold = true }) -- ## Headers
hl("CodeCompanionChatVariable", "variable", { bold = true })
hl("CodeCompanionChatEndOfBuffer", "gray-8")

-- }}}

-- Lazy {{{
hl("LazyButtonActive", "yellow", { bg = "black", bold = true })
hl("LazyButton", "none", { bg = "gray-9" })
hl("LazyCommit", "git-commit")
hl("LazyProp", "orange")
hl("LazyReasonEvent", "orange", { bold = false })
hl("LazyReasonFt", "violet")
hl("LazyReasonPlugin", "yellow")
hl("LazyReasonSource", "violet")
hl("LazyReasonStart", "green")
hl("LazySpecial", "punctuation")
-- }}}

-- Mason {{{
hl("MasonWarning", "warning")
-- }}}}

-- Nvim Tree {{{
hl("NvimTreeClosedFolderIcon", "yellow-5")
hl("NvimTreeOpenedFolderIcon", "yellow-5")
hl("NvimTreeFolderArrowClosed", "neutral")
hl("NvimTreeFolderArrowOpen", "neutral")
hl("NvimTreeGitDirtyIcon", "git-dirty")
hl("NvimTreeRootFolder", "directory")
hl("NvimTreeImageFile", "yellow-5")
-- }}}

-- Icons {{{
hl("DevIconCss", "violet")
hl("DevIconEmbeddedOpenTypeFont", "violet")
hl("DevIconFavicon", "yellow-5")
hl("DevIconJson", "violet")
hl("DevIconJs", "yellow")
hl("DevIconPng", "yellow-5")
hl("DevIconReadme", "amber")
hl("DevIconSvg", "violet")
hl("DevIconTrueTypeFont", "violet")
hl("DevIconWebOpenFontFormat", "violet")
hl("DevIconYml", "violet")
-- }}}

-- GitSigns {{{
-- Lines (:Gitsigns toggle_linehl)
hl("GitSignsAddLn", "none", { bg = "green-9" })
hl("GitSignsChangeLn", "none", { bg = "purple-8" })
hl("GitSignsTopdeleteLn", "none", { bg = "red-8" })
hl("GitSignsDeleteLn", "none", { bg = "red-8" })
-- }}}

-- Avante {{{
-- UI
hl("AvanteSidebarWinSeparator", "gray-8", { bg = "gray-8" }) -- Window seperators
-- Popups
hl("AvanteButtonDefault", "white", { bg = "gray-7" })
hl("AvanteButtonDefaultHover", "amber-1", { bg = "amber-6", bold = true })
hl("AvanteConfirmTitle", "amber-1", { bg = "amber-6", bold = true })
hl("AvanteCommentFg", "neutral")
-- Response
hl("AvanteTitle", "gray-8", { bg = "gray-8" }) -- Avante title
hl("AvanteReversedTitle", "gray-8") -- Avante title sides
hl("AvanteSidebarNormal", "text", { bg = "gray-8" }) -- Normal text
hl("AvanteStateSpinnerToolCalling", "info") -- name of the tool
hl("AvanteStateSpinnerGenerating", "amber-6") -- "generating"
hl("AvanteStateSpinnerSucceeded", "green-1", { bg = "success", bold = true }) -- "succeeded"
hl("AvanteStateSpinnerFailed", "red-1", { bg = "red-6", bold = true })
hl("AvanteTaskCompleted", "success", { bold = true }) -- completed tag
hl("AvanteInlineHint", "neutral") -- Hint on output
-- Files
hl("AvanteSubtitle", "amber-1", { bg = "amber-6" }) -- File title
hl("AvanteReversedSubtitle", "amber-6")
-- Prompt
hl("AvanteThirdTitle", "amber-6", { bg = "amber-6" }) -- Chat title
hl("AvanteReversedThirdTitle", "amber-6")
hl("AvanteSidebarWinHorizontalSeparator", "amber-6", { bg = "gray-8" }) -- Manual separator
hl("AvantePromptInput", "text")
hl("AvantePromptInputBorder", "none", { bg = "gray-6" })
hl("AvantePopupHint", "gray-8", { bg = "gray-8", blend = 100 }) -- Tokens: 3482, etc in chat window
-- hl('Visual', 'WHITE', { bg = 'BLUE', bold = true }) -- Used for keycaps
-- Code
hl("AvanteConflictIncoming", "none", { bg = "green-9" })
hl("AvanteConflictCurrentLabel", "red-4", { bg = "red-8", bold = true })
hl("AvanteConflictIncomingLabel", "green-6", { bg = "green-8", bold = true })
hl("AvanteToBeDeletedWOStrikethrough", "none", { bg = "red-8", strikethrough = true })
-- }}}

-- NeoGit {{{
-- UI
hl("NeogitFloatBorder", "git-commit", { bg = "purple-0" })
hl("NeogitNormal", "gray-3", { bg = "purple-0" })
hl("NeogitPopupBold", "gray-3", { bold = true })
hl("NeogitSignColumn", "none")
hl("NeogitFold", "none")
hl("NeogitPopupSectionTitle", "blue-3", { bold = true })
hl("NeogitPopupActionDisabled", "none")
-- Colors
hl("NeogitGraphBlack", "black")
hl("NeogitGraphBoldBlack", "black", { bold = true })
hl("NeogitGraphBlue", "blue")
hl("NeogitGraphBoldBlue", "blue", { bold = true })
hl("NeogitGraphCyan", "cyan")
hl("NeogitGraphBoldCyan", "cyan", { bold = true })
hl("NeogitGraphGray", "gray")
hl("NeogitGraphBoldGray", "gray", { bold = true })
hl("NeogitGraphGreen", "green")
hl("NeogitGraphBoldGreen", "green", { bold = true })
hl("NeogitGraphOrange", "orange")
hl("NeogitGraphBoldOrange", "orange", { bold = true })
hl("NeogitGraphPurple", "purple")
hl("NeogitGraphBoldPurple", "purple", { bold = true })
hl("NeogitGraphRed", "red")
hl("NeogitGraphBoldRed", "red", { bold = true })
hl("NeogitGraphWhite", "white")
hl("NeogitGraphBoldWhite", "white", { bold = true })
hl("NeogitGraphYellow", "yellow")
hl("NeogitGraphBoldYellow", "yellow", { bold = true })
-- Keybindings
hl("NeogitPopupActionKey", "function")
hl("NeogitPopupSwitchKey", "flag")
hl("NeogitPopupOptionKey", "flag")
hl("NeogitPopupSwitchEnabled", "green-3", { bg = "green-0" })
hl("NeogitPopupOptionDisabled", "red-2", { bg = "red-0" })
hl("NeogitPopupSwitchDisabled", "red-2", { bg = "red-0" })
-- Misc
hl("NeogitBranchHead", "git-branch")
hl("NeogitBranch", "git-branch")
hl("NeogitPopupBranchName", "git-branch")
hl("NeogitObjectId", "git-commit")
hl("NeogitRemote", "git-remote")
hl("NeogitStatusHEAD", "comment")
hl("NeogitFilePath", "file")
-- Sections
hl("NeogitSectionHeaderCount", "number", { bold = true })
hl("NeogitStagedchanges", "git-modified", { bold = true })
hl("NeogitUnstagedchanges", "git-added", { bold = true })
hl("NeogitUntrackedfiles", "git-untracked", { bold = true })
hl("NeogitUnmergedchanges", "git-remote", { bold = true })
hl("NeogitDiffHeader", "yellow-5", { bg = "yellow-0" })
hl("NeogitDiffHeaderCursor", "yellow-5", { bg = "yellow-0" })
hl("NeogitFloatHeader", "blue", { bold = true })
hl("NeogitFloatHeaderHighlight", "blue", { bold = true })
-- Status
hl("NeogitChangeModified", "git-modified")
hl("NeogitChangeNewFile", "git-added")
-- Diff markers
hl("NeogitHunkHeader", "yellow-8", { bg = "yellow-0" })
hl("NeogitHunkHeaderHighlight", "yellow-8", { bg = "yellow-0" })
hl("NeogitHunkHeaderCursor", "yellow-8", { bg = "yellow-0" })
-- Diff add
hl("NeogitDiffAdd", "git-added", { bg = "green-0" })
hl("NeogitDiffAddHighlight", "git-added", { bg = "green-0" })
hl("NeogitDiffAddCursor", "git-added", { bg = "green-0" })
hl("NeogitDiffAdditions", "git-added")
-- Diff deleted
hl("NeogitDiffDelete", "red-7", { bg = "red-0" })
hl("NeogitDiffDeleteHighlight", "red-7", { bg = "red-0" })
hl("NeogitDiffDeleteCursor", "red-7", { bg = "red-0" })
hl("NeogitDiffDeletions", "red-7")
-- Diff unchanged
hl("NeogitDiffContext", "gray-7", { bg = "gray-9" })
hl("NeogitDiffContextHighlight", "gray-7", { bg = "gray-9" })
hl("NeogitDiffContextCursor", "gray-6", { bg = "gray-9" })
-- }}}

-- Notify {{{
hl("NotifyBackground", "none", { bg = "black" })

hl("NotifyDEBUGBody", "notice")
hl("NotifyDEBUGBorder", "notice")
hl("NotifyDEBUGIcon", "notice")
hl("NotifyDEBUGTitle", "notice")
hl("NoiceFormatLevelDebug", "notice")
hl("NoiceODebugNormal", "notice")

hl("NotifyTRACEBody", "text")
hl("NotifyTRACEBorder", "text")
hl("NotifyTRACEIcon", "text")
hl("NotifyTRACETitle", "text")

hl("NotifyINFOIcon", "info")
hl("NotifyINFOTitle", "info")
hl("NotifyINFOBorder", "info")
hl("NotifyINFOBody", "info")

hl("NotifyWARNBody", "warning")
hl("NotifyWARNBorder", "warning")
hl("NotifyWARNIcon", "warning")
hl("NotifyWARNTitle", "warning")

hl("NotifyERRORBody", "error")
hl("NotifyERRORBorder", "error")
hl("NotifyERRORIcon", "error")
hl("NotifyERRORTitle", "error")
-- }}}
