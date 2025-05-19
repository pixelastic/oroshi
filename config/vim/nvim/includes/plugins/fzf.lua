return {
  "junegunn/fzf.vim",
  dependencies = {
    "junegunn/fzf",
  },
  config = function()
    local function openSelectionInNewTabs(selection)
      -- Stop if no selection
      if not next(selection) then
        return
      end

      -- Clean up selection
      local cleanSelection = table.concat(selection, "\n")
      cleanSelection = vim.fn.shellescape(cleanSelection)
      cleanSelection = vim.fn.system('fzf-fs-files-shared-postprocess ' .. cleanSelection)

      vim.cmd('tab drop ' .. cleanSelection)
    end


    -- CTRL-P: {{{
    -- Search in project
    local function onCtrlP()
      local source = vim.fn.systemlist('fzf-fs-files-project-source')
      local options = vim.fn.systemlist('fzf-fs-files-project-options')

      vim.fn['fzf#run']({
        source = source,
        options = options,
        sinklist = openSelectionInNewTabs
      })
    end
    nmap('<C-P>', onCtrlP, 'Search in project')
    imap('<C-P>', onCtrlP, 'Search in project')
    -- }}}

    -- CTRL-T: {{{
    -- Search in current directory
    local function onCtrlT()
      -- Tell fzf what the current directory is
      local currentDir = vim.fn.expand('%:p:h')
      vim.fn.system("fzf-var-write pwd " .. currentDir)

      local source = vim.fn.systemlist('fzf-fs-files-subdir-source')
      local options = vim.fn.systemlist('fzf-fs-files-subdir-options')

      vim.fn['fzf#run']({
        source = source,
        options = options,
        sinklist = openSelectionInNewTabs
      })
    end
    nmap('Ⓟ', onCtrlT, 'Search in current directory')
    imap('Ⓟ', onCtrlT, 'Search in current directory')
    nmap('<C-T>', onCtrlT, 'Search in current directory')
    imap('<C-T>', onCtrlT, 'Search in current directory')
    -- }}}
  end

}
