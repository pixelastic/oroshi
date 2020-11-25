" CTRL-P {{{
" Search all files in the current project and jump to them
"
function! FzfCtrlPSink(line)
  " Open result in new tab, or re-use existing one if already opened
  execute "tab drop " . GetRepoRoot() . "/" . a:line
endfunction

nnoremap <silent> <C-P> :call fzf#run({'source': 'vim-fzf-ctrlp', 'sink': function('FzfCtrlPSink')})<CR>
inoremap <silent> <C-P> <Esc>:call fzf#run({'source': 'vim-fzf-ctrlp', 'sink': function('FzfCtrlPSink')})<CR>
" }}}
"
" fzf#vim#complete allow searching into a list and insert the selection
" " FZF {{{
" " Ctrl-G search in files
" " Ctrl-F search in current file
" " CTRL-G: Search inside of files
" command! -bang -nargs=* FZFCtrlG call fzf#vim#grep("ctrlg", 1, {'options': '--delimiter : --nth 4..'}, <bang>0)
" nnoremap <silent> <C-G> :FZFCtrlG<CR>
" inoremap <silent> <C-G> <Esc>:FZFCtrlG<CR>
" " CTRL-F: Search in this file
" nnoremap <silent> <C-F> :call fzf#run({'source': 'git ls-files', 'sink': 'e'})<CR>
" " N search for word under cursor
" nnoremap N *
" " " CTRL-F: Find line in this file
" " nnoremap <silent> <C-F> :BLines<CR>
" " inoremap <silent> <C-F> <Esc>:BLines<CR>
" " " CTRL-B: Search in git history
" " nnoremap <silent> <C-B> :BCommits<CR>
" " inoremap <silent> <C-B> <Esc>:BCommits<CR>
" " }}}
