" Disable Copilot by default
let b:copilot_enabled = v:false

" Checks if a Copilot suggestion is displayed
" Used by both <Tab> and <Enter> mappings
function! OroshiCopilotSuggestionDisplayed()
  " Nothing displayed if Copilot is disabled
  if b:copilot_enabled ==# v:false
    return v:false
  endif

  " Check the content of the suggestion
  let copilotSuggestion = copilot#GetDisplayedSuggestion()
  return !empty(copilotSuggestion.text)
endfunction
