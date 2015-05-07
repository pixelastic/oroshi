" Syntastic {{{
let g:syntastic_scss_checkers = ['sassc', 'scss_lint']
if !exists('g:syntastic_scss_scss_lint_args') || g:syntastic_scss_scss_lint_args==''
	let g:syntastic_scss_scss_lint_args = '--config ~/.scss-lint.yml'
endif
"}}}

