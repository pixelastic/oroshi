" [CTRL-I] toggles Copilot on/off
function! OroshiCopilotToggle()
  let b:copilot_enabled = !b:copilot_enabled

  " Also color the line numbers
  let lineNrColor = b:copilot_enabled ? 'ALIAS_AI_SUGGESTION' : 'GRAY'
  call OroshiHighlight('LineNr', lineNrColor)
endfunction

nnoremap <silent> ⒤ :call OroshiCopilotToggle()<CR>
"Note: <C-O> exits insert mode for the duration of the mapping
inoremap ⒤ <C-O><Cmd>call OroshiCopilotToggle()<CR>
