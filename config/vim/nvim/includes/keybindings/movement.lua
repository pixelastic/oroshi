-- Start / End of line
nmap("H", "^", "Start of line")
vmap("H", "^", "Start of line")
nmap("L", "g_", "End of line")
vmap("H", "g_", "Start of line")

-- Move line(s) up / down
nmap('-', ':move --<CR>', "Move line up")
vmap('-', ":'<,'>move '<--<CR>gv", "Move line up")
nmap('_', ":move +<CR>", "Move line down")
vmap('_', ":'<,'>move '>+<CR>gv", "Move line down")


-- TODO: Space should repeat
-- TODO: Surround to change the single to double quote
-- TODO: statusline to show the mode
-- TODO: Highlight TODO
-- TODO: Align on comma
-- TODO: Fuzzy search and various tabs

