" STATUS LINE
" Always display the status line
set laststatus=2
" Custom statusline
set statusline=%!OroshiStatusLine()
function! OroshiStatusLine() 
	" " Starting to build the status line
	let sl = ''

	" Current mode {{{
	let sl .= '%#oroshi_StatusLineModeNormal#'
	let sl .= '%{toupper(mode()) == "N" ? "  NORMAL " : ""}'
	let sl .= '%*'
	let sl .= '%#oroshi_StatusLineModeNormalArrow#'
	let sl .= '%{toupper(mode()) == "N" ? "⮀ " : ""}'
	let sl .= '%*'

	let sl .= '%#oroshi_StatusLineModeInsert#'
	let sl .= '%{toupper(mode()) == "I" ? "  INSERT " : ""}'
	let sl .= '%*'
	let sl .= '%#oroshi_StatusLineModeInsertArrow#'
	let sl .= '%{toupper(mode()) == "I" ? "⮀ " : ""}'
	let sl .= '%*'

	let sl .= '%#oroshi_StatusLineModeVisual#'
	let sl .= '%{mode() =~# "\\v(V|v|)" ? "  VISUAL " : ""}'
	let sl .= '%*'
	let sl .= '%#oroshi_StatusLineModeVisualArrow#'
	let sl .= '%{mode() =~# "\\v(V|v|)" ? "⮀ " : ""}'
	let sl .= '%*'

	let sl .= '%#oroshi_StatusLineModeSearch#'
	let sl .= '%{mode() == "C" ? "  SEARCH " : ""}'
	let sl .= '%*'
	let sl .= '%#oroshi_StatusLineModeSearchArrow#'
	let sl .= '%{mode() == "C" ? "⮀ " : ""}'
	let sl .= '%*'
	" }}}
	" Filename coloring based on readonly, modified and saved {{{
	let sl .= '%#oroshi_StatusLineReadOnly#'
	let sl .= '%{&readonly == 1 ? expand(''%:t'')." ⭤ " : ""}'
	let sl .= '%*'
	let sl .= '%#oroshi_StatusLineModified#'
	let sl .= '%{&readonly == 0 && &modified == 1 ? expand(''%:t'')." " : ""}'
	let sl .= '%*'
	let sl .= '%#oroshi_StatusLineSaved#'
	let sl .= '%{&readonly == 0 && &modified == 0 ? expand(''%:t'')." " : ""}'
	let sl .= '%*'
	" }}}
	" Git status {{{
	let sl .= '%#oroshi_StatusLineGitDirty#'
	let sl .= '%{exists("b:git_status") && b:git_status == "dirty" ? "± " : ""}'
	let sl .= '%*'
	let sl .= '%#oroshi_StatusLineGitStaged#'
	let sl .= '%{exists("b:git_status") && b:git_status == "staged" ? "± " : ""}'
	let sl .= '%*'
	let sl .= '%#oroshi_StatusLineGitClean#'
	let sl .= '%{exists("b:git_status") && b:git_status == "clean" ? "± " : ""}'
	let sl .= '%*'
	" }}}
	" Tests passing or not {{{
	let sl .= '%#oroshi_TestPassSuccess#'
	let sl .= '%{exists("b:arval_test_pass") && b:arval_test_pass == 1 ? "✔" : ""}'
	let sl .= '%*'
	let sl .= '%#oroshi_TestPassFailure#'
	let sl .= '%{exists("b:arval_test_pass") && b:arval_test_pass == 0 ? "✘" : ""}'
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
	let sl .= '%#oroshi_StatusLineBadLineEnding#'
	let sl .= '%{&fileformat != "unix" ? &fileformat." " : ""}'
	let sl .= '%*'
	" }}}
	" File encoding {{{
	let sl .= '%#oroshi_StatusLineBadEncoding#'
	let sl .= '%{&fileencoding != "utf-8" ? &fileencoding." " : ""}'
	let sl .= '%*'
	" }}}
	" Filetype {{{
	let sl .= '⭢⭣ %{&filetype != "" ? &filetype : "???"} '
	" }}}
	" Ruler {{{
	let sl .= "⭡ %2.3c/%{&textwidth},%4l/%3L,%3p%%"
	" }}}

	return sl
endfunction
