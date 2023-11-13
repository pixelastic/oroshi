" [CTRL-I] toggles Copilot on/off
function! OroshiCopilotToggle()
  let b:copilot_enabled = !b:copilot_enabled
endfunction

nnoremap <silent> ⒤ :call OroshiCopilotToggle()<CR>
"Note: <C-O> exits insert mode for the duration of the mapping
inoremap ⒤ <C-O><Cmd>call OroshiCopilotToggle()<CR>
