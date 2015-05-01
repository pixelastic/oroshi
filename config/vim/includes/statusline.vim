" STATUS LINE
" Always display the status line
set laststatus=2
" Custom statusline
set statusline=%!OroshiStatusLine()
function! OroshiStatusLine() 
  " Starting to build the status line
  let sl = ''

  " Current mode {{{
  let sl .= '%#oroshi_ModeNormal#'
  let sl .= '%{toupper(mode()) == "N" ? "  NORMAL " : ""}'
  let sl .= '%*'
  let sl .= '%#oroshi_UIModeNormal#'
  let sl .= '%{toupper(mode()) == "N" ? "⮀ " : ""}'
  let sl .= '%*'

  let sl .= '%#oroshi_ModeInsert#'
  let sl .= '%{toupper(mode()) == "I" ? "  INSERT " : ""}'
  let sl .= '%*'
  let sl .= '%#oroshi_UIModeInsert#'
  let sl .= '%{toupper(mode()) == "I" ? "⮀ " : ""}'
  let sl .= '%*'

  let sl .= '%#oroshi_ModeVisual#'
  let sl .= '%{mode() =~# "\\v(V|v|)" ? "  VISUAL " : ""}'
  let sl .= '%*'
  let sl .= '%#oroshi_UIModeVisual#'
  let sl .= '%{mode() =~# "\\v(V|v|)" ? "⮀ " : ""}'
  let sl .= '%*'

  let sl .= '%#oroshi_ModeSearch#'
  let sl .= '%{mode() == "C" ? "  SEARCH " : ""}'
  let sl .= '%*'
  let sl .= '%#oroshi_UIModeSearch#'
  let sl .= '%{mode() == "C" ? "⮀ " : ""}'
  let sl .= '%*'
  " }}}
  " Filename coloring based on readonly, modified and saved {{{
  let sl .= '%#oroshi_UIError#'
  let sl .= '%{&readonly == 1 ? expand(''%:t'')." ⭤ " : ""}'
  let sl .= '%*'
  let sl .= '%#oroshi_UINotice#'
  let sl .= '%{&readonly == 0 && &modified == 1 ? expand(''%:t'')." " : ""}'
  let sl .= '%*'
  let sl .= '%#oroshi_UISuccess#'
  let sl .= '%{&readonly == 0 && &modified == 0 ? expand(''%:t'')." " : ""}'
  let sl .= '%*'
  " }}}
  " Git status {{{
  let sl .= '%#oroshi_UIError#'
  let sl .= '%{exists("b:git_status") && b:git_status == "dirty" ? "± " : ""}'
  let sl .= '%*'
  let sl .= '%#oroshi_UINotice#'
  let sl .= '%{exists("b:git_status") && b:git_status == "staged" ? "± " : ""}'
  let sl .= '%*'
  let sl .= '%#oroshi_UISuccess#'
  let sl .= '%{exists("b:git_status") && b:git_status == "clean" ? "± " : ""}'
  let sl .= '%*'
  " }}}
  " Syntastic status {{{
  let sl .= '%#oroshi_UIError#'
  let sl .= '%e%{SyntasticStatuslineFlag()}'
  let sl .= '%*'
  " }}}
  " Right / Left separator {{{
  let sl .= '%='
  " }}}
  " Debug var {{{
  let sl .= '%{exists("b:o_debug") ? "B[".b:o_debug."] " : ""}'
  let sl .= '%{exists("g:o_debug") ? "G[".g:o_debug."] " : ""}'
  " }}}
  " Foldmarker {{{
  let sl .= '%{&foldmethod == "manual" ? "M " : ""}'
  let sl .= '%{&foldmethod == "marker" ? "{ " : ""}'
  let sl .= '%{&foldmethod == "syntax" ? "S " : ""}'
  let sl .= '%{&foldmethod == "indent" ? "▸ " : ""}'
  " }}}
  " Line endings {{{
  let sl .= '%#oroshi_UIError#'
  let sl .= '%{&fileformat != "unix" ? &fileformat." " : ""}'
  let sl .= '%*'
  " }}}
  " File encoding {{{
  let sl .= '%#oroshi_UIError#'
  let sl .= '%{&fileencoding != "utf-8" ? &fileencoding." " : ""}'
  let sl .= '%*'
  " }}}
  " Spellchecking {{{
  let sl .= '%{&spell == 1 ? "  ".&spelllang." " : ""}'
  "
  " }}}
  " Filetype {{{
  let sl .= '⭢⭣ %{&filetype != "" ? &filetype : "???"} '
  " }}}
  " Ruler {{{
  let sl .= " ⭡"
  let sl.= " 0x%2.B" " current char
  let sl.=" %2.c/%2.{&textwidth}" " current colum / max columns
  let sl.=" %3l/%3L" " current line / max line
  let sl.=" %3p%%" " percentage in file
  " }}}

  return sl
endfunction
