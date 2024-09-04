" Helper function to colorize a string
" Usage:
" Colorize('my string', 'TabLine')     # Returns my string wrapped in TabLine color
function! Colorize(input, color)
  return '%#' . a:color . '#' . a:input . '%*'
endfunction
