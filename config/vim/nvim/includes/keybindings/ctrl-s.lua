-- CTRL + S
-- Save the current file
vim.keymap.set(
	{ "i", "n", "v" }, 
	"<C-S>", 
	"<CMD>w<CR><ESC>", 
	{ desc = "Save file" }
)
