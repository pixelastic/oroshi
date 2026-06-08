-- Make sure all other config is loaded from the correct oroshi worktree
vim.opt.runtimepath:prepend(vim.env.OROSHI_ROOT .. "/tools/vim/nvim/config")

require("oroshi/index")
