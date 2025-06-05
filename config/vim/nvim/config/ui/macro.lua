local autocmd = F.autocmd

-- Save name of currently recorded macro for statusline
local function setIsRecording(status)
  return function()
    if status then
      O.statusline.macroName = vim.fn.reg_recording()
    else
      O.statusline.macroName = nil
    end

    vim.cmd("redrawstatus")
  end
end
autocmd('RecordingEnter', setIsRecording(true))
autocmd('RecordingLeave', setIsRecording(false))
