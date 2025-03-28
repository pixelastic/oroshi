" Check if the current file is a zx file
function! JavaScriptIsZx()
  return getline(1) == '#!/usr/bin/env zx'
endfun
