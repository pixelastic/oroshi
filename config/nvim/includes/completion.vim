" COMPLETION
set pumheight=10          " Height of the (scrollable) autocompletion window
set completeopt+=menuone  " Display the menu even if there is only one match
" set completeopt+=noinsert " Only update the text once an item is selected
" set completeopt+=noselect
" set shortmess+=c          " Shut off completion messages

" TODO: Completion of directories should add the final / when selecting one,
" allowing for chaining path
" TODO: Completion of files should not suggest buffer if no path found
" TODO: Omnifunc should be enabled, to initially suggest variables of the
" current file
