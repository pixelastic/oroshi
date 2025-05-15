-- Capslock
-- Switch between Normal and Insert mode
-- Note: Capslock actually sends <F13> on my keyboard

vim.keymap.set("i", "<F13>", "<Esc>l")  -- Insert  => Normal
vim.keymap.set("n", "<F13>", "i")       -- Normal  => Insert
vim.keymap.set("v", "<F13>", "<Esc>")   -- Visual  => Normal
vim.keymap.set("c", "<F13>", "<Esc>")   -- Command => Normal
