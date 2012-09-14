" NGINX
" Commenting with #
setlocal commentstring=#\ %s
" Folding with language { and }
setlocal foldmethod=marker
setlocal foldmarker={,}
" Custom folding text method
setlocal foldtext=NginxFoldText()
function! NginxFoldText()
	" We get the default title
	let title = StrUncomment(getline(v:foldstart))

	" server {server_name}:{listen}
	if title =~ "server"
		let lines = getline(v:foldstart, v:foldend)
		" Finding server name and listen port from fold
		for line in lines
			if line =~ "server_name"
				let serverName = substitute(line, '^\s*server_name\s*\(.*\);$', '\1',  '')
				continue
			endif
			if line =~ "listen"
				let listenPort = substitute(line, '^\s*listen\s*\(.*\);$', '\1',  '')
			endif
		endfor
		" Adding it to the title
		if exists('serverName')
			let title .= ' ' . serverName
		endif
		if exists('listenPort')
			let title .= ':' . listenPort
		endif
	endif

	return OroshiFoldText(title)
endfunction
