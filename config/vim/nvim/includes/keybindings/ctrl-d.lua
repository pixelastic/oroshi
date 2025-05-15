-- CTRL + D
-- Save and close the file
vim.keymap.set(
	{ "i", "n", "v"}, 
	"<C-D>", 
	"<CMD>x<CR><ESC>", 
	{ desc = "Save file and quit" }
)
