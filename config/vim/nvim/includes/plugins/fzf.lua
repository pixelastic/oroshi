return {
  -- https://github.com/junegunn/fzf.vim
  -- Fuzzy search in files and regex
  -- enabled = false,
  "junegunn/fzf.vim",
  dependencies = {
    "junegunn/fzf",
  },
  config = function()
    -- Specific config for the fzf buffer
    ftplugin('fzf', function()
      -- Display a simpler name in the buffer
      vim.api.nvim_buf_set_name(0, "[FZF]")

      -- Hide part of the UI when opening
      local originalShowmode = vim.opt.showmode;
      local originalRuler = vim.opt.ruler;
      local originalLaststatus = vim.opt.laststatus;
      local originalShowtabline = vim.opt.showtabline;

      vim.opt.showmode = false;
      vim.opt.ruler = false;
      vim.opt.laststatus = 0;
      vim.opt.showtabline = 0;

      -- Revert to previous settings when closing
      local function restorePreviousSettings()
        vim.opt.showmode = originalShowmode
        vim.opt.ruler = originalRuler
        vim.opt.laststatus = originalLaststatus;
        vim.opt.showtabline = originalShowtabline;
      end
      autocmd('BufLeave', "*", restorePreviousSettings, { buffer = vim.api.nvim_get_current_buf() })
    end)

    -- openFilesInNewTabs {{{
    -- Used when selecting (multiple) filepaths
    local function openFilesInNewTabs(selection)
      -- Stop if no selection
      if not next(selection) then
        return
      end

      -- Clean up selection
      local cleanSelection = table.concat(selection, "\n")
      cleanSelection = vim.fn.shellescape(cleanSelection)
      cleanSelection = vim.fn.system('fzf-fs-files-shared-postprocess ' .. cleanSelection)

      -- Opening them all, one in each tab, re-using existing tabs
      vim.cmd('tab drop ' .. cleanSelection)
    end
    -- }}}

    -- openLinesInNewTabs {{{
    local function openLinesInNewTabs(selection)
      -- Stop if no selection
      if not next(selection) then
        return
      end

      -- Clean up selection
      local cleanSelection = table.concat(selection, "\n")
      cleanSelection = vim.fn.shellescape(cleanSelection)
      cleanSelection = vim.fn.system('fzf-regexp-shared-postprocess ' .. cleanSelection)

      -- Opening each filepath, one by one, and moving to the selected line
      local items = vim.split(cleanSelection, " ", { trimempty = true })
      for _, item in ipairs(items) do
        local filepath, line = item:match("(.+):(.+)")
        vim.cmd('tab drop ' .. filepath)
        vim.cmd(line)
      end
    end
    -- }}}


    -- CTRL-P: {{{
    -- Search in project
    local function onCtrlP()
      -- Tell fzf what the root directory is
      local rootDirectory = vim.fn.system('git-directory-root -f')
      vim.fn.system("fzf-var-write pwd " .. rootDirectory)

      local source = vim.fn.systemlist('fzf-fs-files-project-source')
      local options = vim.fn.systemlist('fzf-fs-files-project-options')

      vim.fn['fzf#run']({
        source = source,
        options = options,
        sinklist = openFilesInNewTabs
      })
    end
    nmap('<C-P>', onCtrlP, 'Search in project')
    vmap('<C-P>', onCtrlP, 'Search in project')
    imap('<C-P>', onCtrlP, 'Search in project')
    -- }}}

    -- CTRL-T: {{{
    -- Search in current directory
    local function onCtrlT()
      -- Tell fzf what the base directory is
      local subdirPath = vim.fn.expand('%:p:h')
      vim.fn.system("fzf-var-write pwd " .. subdirPath)

      local source = vim.fn.systemlist('fzf-fs-files-subdir-source')
      local options = vim.fn.systemlist('fzf-fs-files-subdir-options')

      vim.fn['fzf#run']({
        source = source,
        options = options,
        sinklist = openFilesInNewTabs
      })
    end
    nmap('Ⓟ', onCtrlT, 'Search in current directory')
    imap('Ⓟ', onCtrlT, 'Search in current directory')
    vmap('Ⓟ', onCtrlT, 'Search in current directory')
    nmap('<C-T>', onCtrlT, 'Search in current directory')
    imap('<C-T>', onCtrlT, 'Search in current directory')
    vmap('<C-T>', onCtrlT, 'Search in current directory')
    -- }}}
    
    -- CTRL-G: {{{
    -- Regex search inside of files
    local function onCtrlG()
      -- Tell fzf what the root directory is
      local rootDirectory = vim.fn.system('git-directory-root -f')
      vim.fn.system("fzf-var-write pwd " .. rootDirectory)

      local source = {}
      local options = vim.fn.systemlist('fzf-regexp-project-options')

      vim.fn['fzf#run']({
        source = source,
        options = options,
        sinklist = openLinesInNewTabs
      })
    end
    nmap('<C-G>', onCtrlG, 'Regex search in files')
    imap('<C-G>', onCtrlG, 'Search in current directory')
    -- }}}

    -- CTRL-SHIFT-G: {{{
    -- Regex search inside of files in the current directory
    local function onCtrlShiftG()
      -- Tell fzf what the base directory is
      local subdirPath = vim.fn.expand('%:p:h')
      vim.fn.system("fzf-var-write pwd " .. subdirPath)

      local source = {}
      local options = vim.fn.systemlist('fzf-regexp-subdir-options')

      vim.fn['fzf#run']({
        source = source,
        options = options,
        sinklist = openLinesInNewTabs
      })
    end
    nmap('Ⓖ', onCtrlShiftG, 'Regex search in files')
    imap('Ⓖ', onCtrlShiftG, 'Search in current directory')
    -- }}}
  end

}
