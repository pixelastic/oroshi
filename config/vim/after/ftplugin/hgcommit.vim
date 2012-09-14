" HGCOMMIT
" Saves commit with Ctrl+S
nnoremap <buffer> <C-S> :x<CR>
inoremap <buffer> <C-S> <Esc>:x<CR>
" Discard commit with Ctrl+D
nnoremap <buffer> <C-D> :q!<CR>
inoremap <buffer> <C-D> <Esc>:q!<CR>
" Start in insert mode to type the message
" au BufEnter <buffer> call feedkeys('ggi', 't')
" Comments are HG:
setlocal commentstring=HG:\ %s

" Add the hg diff at the end of the commit, like `git commit -v` does
au BufEnter <buffer> call AppendHgDiff()
function! AppendHgDiff() 
	" Stop if no diff available
	let hgDiffFile="/tmp/hg-diff.txt"
	if !filereadable(hgDiffFile)
		return
	endif

	normal mz

	" Append diff to file
	call append(line('$'), ['HG: --'])
	let lastLine = line('$')
	let hgDiff = readfile(hgDiffFile)
	call append(lastLine, hgDiff)
	" Comment it out
	execute 'silent! '.(lastLine+1).',$s/\v^(.*)$/HG: \1/g'

	normal `z
endfunction
