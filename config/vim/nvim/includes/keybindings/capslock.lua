-- Capslock
-- Switch between Normal and Insert mode
-- Note: Capslock actually sends <F13> on my keyboard
imap("<F13>", "<Esc>l", "Insert  => Normal")
nmap("<F13>", "i", "Normal  => Insert")
vmap("<F13>", "<Esc>", "Visual  => Normal")
cmap("<F13>", "<Esc>", "Command => Normal")
