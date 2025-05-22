return {
  -- https://github.com/tpope/vim-eunuch
  -- Used to :Rename and :Delete files
  -- enabled = false,
  "tpope/vim-eunuch",
  config = function()
    -- CTRL + Shift + M: Rename
    imap("Ⓜ", "<Esc>:Rename<Space>", "Rename file", { silent = false })
    nmap("Ⓜ", ":Rename<Space>", "Rename file", { silent = false })
    vmap("Ⓜ", "<Esc>:Rename<Space>", "Rename file", { silent = false })

    -- CTRL + Del
    local function deleteCurrentFile()
      -- We delete the file
      vim.cmd('Delete!')

      -- The rest of the function will handle the edge case where the file we
      -- just deleted was the last opened file in vim, in which case, we will
      -- close vim. In another case, we keep working as usual

      -- More than one tab opened? We keep working
      local totalTabs = vim.fn.tabpagenr('$')
      if totalTabs ~= 1 then return end

      -- Finding the currently opened buffer
      local allBuffers = vim.api.nvim_list_bufs()
      local listedBuffers = vim.tbl_filter(vim.api.nvim_buf_is_loaded, allBuffers)
      local currentBuffer = listedBuffers[1]

      -- The last buffer has a name? We keep working
      local bufferName = vim.api.nvim_buf_get_name(currentBuffer)
      if bufferName ~= '' then return end

      -- The last buffer has a type? We keep working
      local bufferType = vim.api.nvim_buf_get_option(currentBuffer, 'buftype')
      if bufferType ~= '' then return end

      -- The last buffer has more than one line? We keep working
      local bufferLineCount = vim.api.nvim_buf_line_count(currentBuffer)
      if bufferLineCount > 1 then return end
      
      -- The only line has content? We keep working
      local bufferFirstLine = vim.api.nvim_get_current_line()
      if bufferFirstLine ~= '' then return end

      -- At that stage, we're confident we can exit vim
      vim.cmd('exit')
    end
    imap("<C-Del>", deleteCurrentFile, "Delete current file")
    nmap("<C-Del>", deleteCurrentFile, "Delete current file")
    vmap("<C-Del>", deleteCurrentFile, "Delete current file")



  end
}
