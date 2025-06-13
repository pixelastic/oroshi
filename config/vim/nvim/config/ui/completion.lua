local autocmd = F.autocmd

-- Ghost text

-- GOAL: I want "Ghost text", ie. the first suggestion displayed as I type, that
-- I can confirm with <Tab>. 
--
-- PROBLEM: nvim-cmp can provide that, but only if the dropdown menu of ALL
-- suggestions is displayed as I type. I don't want suggestions always popping,
-- I find this distracting.
--
-- SOLUTION: So I cheat. I keep the display of suggestions, but not as a
-- dropdown below the cursor, but in the "wildmenu" bar (displayed above the
-- command line). 
--
-- If I set the cmdheight to 0 though, it now displayed above the statusbar, no
-- longer hiding it. I set its text and background to black, and it is now
-- hidden.
--
-- There is still the message area that sometimes get displayed over the
-- statusbar, but by setting its highlight group background to transparent, we
-- can make this disappear.
--
-- Finally, I need to change the cmdheight back to 1 when I type a command or a
-- search
vim.opt.cmdheight = 0  -- Hide the command line

-- Hide / Show the completion menu {{{
-- F.hideCompletionWildmenu()
-- F.showCompletionWildmenu()
-- autocmd('CmdlineEnter',  F.showCompletionWildmenu)
-- autocmd('CmdlineLeave',  F.hideCompletionWildmenu)
-- }}}
