" VUE
" Linters {{{
let b:syntastic_checkers = ['pug_lint_vue', 'eslint']
let b:syntastic_vue_eslint_exec = StrTrim(system('npm-which eslint'))
" }}}
