-- Disk
-- Navigate, rename, delete files
local nmap = F.nmap
local imap = F.imap
local vmap = F.vmap
local ftplugin = F.ftplugin
local autocmd = F.autocmd

return {
  -- Eunuch
  -- https://github.com/tpope/vim-eunuch
  -- Used to :Rename and :Delete files
  {
    "tpope/vim-eunuch",
    config = function()
      -- CTRL + Shift + M: Rename
      nmap("Ⓜ", ":Rename<Space>", "Rename file", { silent = false })
      imap("Ⓜ", "<Esc>:Rename<Space>", "Rename file", { silent = false })
      vmap("Ⓜ", "<Esc>:Rename<Space>", "Rename file", { silent = false })
      vim.cmd([[cnoreabbrev rename Rename]]) -- Allow for :rename as well

      -- CTRL + Del
      local function deleteCurrentFile()
        -- We delete the file
        vim.cmd("Delete!")

        -- The rest of the function will handle the edge case where the file we
        -- just deleted was the last opened file in vim, in which case, we will
        -- close vim. In another case, we keep working as usual

        -- More than one tab opened? We keep working
        if F.tabCount() ~= 1 then
          return
        end

        -- Finding the currently opened buffer
        local currentBuffer = F.first(F.buffers())

        -- The last buffer has a name? We keep working
        local bufferName = F.bufferName(currentBuffer)
        if bufferName ~= "" then
          return
        end

        -- The last buffer has a type? We keep working
        local bufferType = F.bufferOption("buftype", currentBuffer)
        if bufferType ~= "" then
          return
        end

        -- The last buffer has more than one line? We keep working
        local bufferLineCount = F.lineCount(currentBuffer)
        if bufferLineCount > 1 then
          return
        end

        -- The only line has content? We keep working
        local bufferFirstLine = F.line(1, currentBuffer)
        if bufferFirstLine ~= "" then
          return
        end

        -- At that stage, we're confident we can exit vim
        vim.cmd("exit")
      end

      imap("<C-Del>", deleteCurrentFile, "Delete current file")
      nmap("<C-Del>", deleteCurrentFile, "Delete current file")
      vmap("<C-Del>", deleteCurrentFile, "Delete current file")
    end,
  },

  -- Fzf
  -- https://github.com/junegunn/fzf.vim
  -- Fuzzy search in files and regex
  {
    "junegunn/fzf.vim",
    dependencies = {
      "junegunn/fzf",
    },
    config = function()
      -- Specific config for the fzf buffer
      ftplugin("fzf", function()
        -- Display a simpler name in the buffer
        vim.api.nvim_buf_set_name(0, "[FZF]")

        -- Hide part of the UI when opening
        local originalShowmode = vim.opt.showmode
        local originalRuler = vim.opt.ruler
        local originalLaststatus = vim.opt.laststatus
        local originalShowtabline = vim.opt.showtabline

        vim.opt.showmode = false
        vim.opt.ruler = false
        vim.opt.laststatus = 0
        vim.opt.showtabline = 0

        -- Revert to previous settings when closing
        local function restorePreviousSettings()
          vim.opt.showmode = originalShowmode
          vim.opt.ruler = originalRuler
          vim.opt.laststatus = originalLaststatus
          vim.opt.showtabline = originalShowtabline
        end
        autocmd("BufLeave", restorePreviousSettings, { buffer = F.bufferId() })
      end)

      -- openFilesInNewTabs {{{
      -- Opens each selected file in a new tab.
      local function openFilesInNewTabs(selection, postprocessCmd)
        -- Stop if no selection
        if F.isEmpty(selection) then
          return
        end

        F.each(selection, function(line)
          local result = vim.fn.system(postprocessCmd, line)
          result = F.trim(result)
          if result ~= "" then
            F.openTab(result)
          end
        end)
      end
      -- }}}

      -- openLinesInNewTabs {{{
      -- Opens each regexp match in a new tab at the matched line.
      -- Each selected line is piped through postprocessCmd → file:line:col
      local function openLinesInNewTabs(selection, postprocessCmd)
        -- Stop if no selection
        if F.isEmpty(selection) then
          return
        end

        F.each(selection, function(line)
          local result = vim.fn.system(postprocessCmd, line)
          result = F.trim(result)
          if result == "" then
            return false
          end

          local parts = F.split(result, ":")
          local filepath = parts[1]
          local lineNum = tonumber(parts[2])
          if filepath and lineNum then
            F.openTab(filepath)
            F.moveTo(lineNum)
          end
        end)
      end
      -- }}}

      -- CTRL-P: {{{
      -- Search in project
      local function onCtrlP()
        local options = vim.fn.systemlist("ctrl-p --options")

        vim.fn["fzf#run"]({
          source = "ctrl-p --source",
          options = options,
          sinklist = function(selection)
            openFilesInNewTabs(selection, "ctrl-p --postprocess")
          end,
        })
      end
      nmap("<C-P>", onCtrlP, "Search in project")
      vmap("<C-P>", onCtrlP, "Search in project")
      imap("<C-P>", onCtrlP, "Search in project")
      -- }}}

      -- CTRL-SHIFT-P: {{{
      -- Search in current directory
      local function onCtrlShiftP()
        local options = vim.fn.systemlist("ctrl-shift-p --options")

        vim.fn["fzf#run"]({
          source = "ctrl-shift-p --source",
          options = options,
          sinklist = function(selection)
            openFilesInNewTabs(selection, "ctrl-shift-p --postprocess")
          end,
        })
      end
      nmap("Ⓟ", onCtrlShiftP, "Search in current directory")
      imap("Ⓟ", onCtrlShiftP, "Search in current directory")
      vmap("Ⓟ", onCtrlShiftP, "Search in current directory")
      -- }}}

      -- CTRL-G: {{{
      -- Regex search inside of files
      local function onCtrlG()
        local source = vim.fn.systemlist("ctrl-g --source")
        local options = vim.fn.systemlist("ctrl-g --options")

        vim.fn["fzf#run"]({
          source = source,
          options = options,
          sinklist = function(selection)
            openLinesInNewTabs(selection, "ctrl-g --postprocess")
          end,
        })
      end
      nmap("<C-G>", onCtrlG, "Regex search in files")
      vmap("<C-G>", onCtrlG, "Regex search in files")
      imap("<C-G>", onCtrlG, "Regex search in files")
      -- }}}

      -- CTRL-SHIFT-G: {{{
      -- Regex search inside of files in the current directory
      local function onCtrlShiftG()
        local source = vim.fn.systemlist("ctrl-shift-g --source")
        local options = vim.fn.systemlist("ctrl-shift-g --options")

        vim.fn["fzf#run"]({
          source = source,
          options = options,
          sinklist = function(selection)
            openLinesInNewTabs(selection, "ctrl-shift-g --postprocess")
          end,
        })
      end
      nmap("Ⓖ", onCtrlShiftG, "Regex search in files")
      vmap("Ⓖ", onCtrlShiftG, "Regex search in files")
      imap("Ⓖ", onCtrlShiftG, "Regex search in files")
      -- }}}
    end,
  },

  -- Nvim Tree
  -- https://github.com/nvim-tree/nvim-tree.lua
  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    version = "1.12.0",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      -- Disable netrw as to not interfere with the tree
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      nmap("<C-!>", "<cmd>NvimTreeToggle<CR>", "Toggle file explorer")
      imap("<C-!>", "<ESC><cmd>NvimTreeToggle<CR>", "Toggle file explorer")

      local function onAttach(bufnr)
        local api = require("nvim-tree.api")

        -- Disable Insert Mode
        nmap("<F13>", "", "Disable Insert mode", { buffer = bufnr })
        nmap("i", "", "Disable Insert mode", { buffer = bufnr })

        -- H: Go up one level {{{
        local function onH()
          api.tree.change_root_to_parent()
        end
        nmap("h", onH, "Go up one level", { buffer = bufnr })
        --- }}}

        -- L: Open {{{
        local function onL()
          local node = api.tree.get_node_under_cursor()

          -- Directories
          if node.nodes ~= nil then
            api.node.open.edit()
            return
          end

          -- Files
          local currentTab = vim.fn.tabpagenr()
          api.node.open.tab_drop(node) -- Open in new tab, or re-use existing if possible
          vim.cmd.tabnext(currentTab) -- Go back to initial tab
          api.tree.open() -- Keep focus on the tree
        end
        nmap("l", onL, "Open silently", { buffer = bufnr })
        --- }}}

        -- ENTER: {{{
        --   on folders: Open/Close
        --   on files: Open in new tab, and close the tree
        local function onEnter()
          local node = api.tree.get_node_under_cursor()

          -- Directories
          if node.nodes ~= nil then
            api.node.open.edit()
            return
          end

          -- Files
          local currentTab = vim.fn.tabpagenr()
          api.tree.close() -- Keep focus on the tree
          api.node.open.tab_drop(node) -- Open in new tab, or re-use existing if possible
        end
        nmap("<CR>", onEnter, "Open immediatly", { buffer = bufnr })
        --- }}}

        -- CTRL+N: {{{
        -- Create a new file
        local function onCtrlN()
          api.fs.create()
        end
        nmap("<C-N>", onCtrlN, "Create new file", { buffer = bufnr })
      end

      O.nvimtree.currentDirectory = nil

      local nvimtree = require("nvim-tree")
      local api = nvimtree.api
      nvimtree.setup({
        view = { width = 30 },
        on_attach = onAttach,

        -- Display only folder name on top
        renderer = {
          root_folder_label = function(path)
            -- Set the current directory, for display in the statusline
            O.nvimtree.currentDirectory = path

            local basename = vim.fs.basename(path) .. "/"
            return basename
          end,
        },
      })
    end,
  },
}
