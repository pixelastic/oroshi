return {
  -- https://github.com/windwp/nvim-autopairs
  -- Auto close quotes as you type
  -- enabled = false,
  'windwp/nvim-autopairs',
  event = "InsertEnter",
  opts = {
    check_ts = true
  }
}
