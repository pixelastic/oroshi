scriptencoding utf-8
" ALE lints files
" https://github.com/dense-analysis/ale
" It's Syntastic successor, and check files for linting errors and display them.
" It calls external tools in the background to do the linting.
"
" Note: Supported linters
" https://github.com/dense-analysis/ale/blob/master/supported-tools.md
"
" Note: Use :ALEInfo to see the defined vars
" Note: Use :ALEFixSuggest for ideas of potential fixers
"
" TODO: Display the number of errors in the status line

" When to lint
let g:ale_lint_on_text_changed = 'never' " Do not lint while typing
let g:ale_lint_on_insert_leave = 0       " Do not lint when leaving insert mode
let g:ale_lint_on_enter = 'never'        " Do not lint when opening the file
let g:ale_lint_on_save = 0               " Do not lint on save (we use Lint())
let g:ale_fix_on_save = 0                " Do not fix on save (we use Lint())

" How to fix
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'json': ['prettier'],
\   'yml': ['prettier'],
\}

" How to lint
" Any filetype not defined will use the default list for this language. I prefer
" to write my lists explicitly, so they don't depend on what is installed on the
" current machine.
let g:ale_linters = {
\   'json': ['jsonlint', 'prettier'],
\   'sh': ['shellcheck'],
\   'vim': ['vint'],
\   'yml': ['yamllint'],
\}
let b:ale_vim_vint_executable = '/home/tim/.pyenv/shims/vint' " vint is loaded through pyenv



let g:ale_sign_error = ' '               " Error sign in gutter
let g:ale_sign_warning = ' '             " Warning sign in gutter
let g:ale_virtualtext_cursor = 'disabled' " Do not display errors in virtual text
