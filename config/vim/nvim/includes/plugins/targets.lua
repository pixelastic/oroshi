return {
  -- https://github.com/wellle/targets.vim
  -- Lots of new operators to select elements
  -- enabled = false,
  "wellle/targets.vim",
  config = function()
    -- Arguments
    nmap('via', 'vIa', 'Select an argument', { remap = true })
    nmap('cia', 'cIa', 'Change an argument', { remap = true })
    nmap('dia', 'daa', 'Delete an argument', { remap = true })
  end
}
