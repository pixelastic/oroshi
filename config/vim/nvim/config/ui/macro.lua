-- Keep reference to if we are recording a macro (to display in statusline)
__.macro = {
  currentName = nil
}

-- Switch a boolean when recording a macro
local function setIsRecording(status)
  return function()
    if status then
      __.macro.currentName = vim.fn.reg_recording()
    else
      __.macro.currentName = nil
    end

    vim.cmd("redrawstatus")
  end
end
autocmd('RecordingEnter', '*', setIsRecording(true))
autocmd('RecordingLeave', '*', setIsRecording(false))
