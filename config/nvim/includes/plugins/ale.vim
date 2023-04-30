scriptencoding utf-8
" ALE lints files
" https://github.com/dense-analysis/ale
" It's Syntastic successor, and check files for linting errors and display them.
" It calls external tools in the background to do the linting.
"
" Note: Supported linters
" https://github.com/dense-analysis/ale/blob/master/supported-tools.md
"
" Note: Ale fix and Neoformat might overlap. The rule of thumb is to use Ale fix
" in priority and if a fixer is not available, use neoformat instead.
"
" Note: Use :ALEInfo to see the defined vars Note: Use :ALEFixSuggest for ideas
" of potential fixers
"
" TODO: Display the number of errors in the status line

" When to lint
let g:ale_lint_on_text_changed = 'never' " Do not lint while typing
let g:ale_lint_on_insert_leave = 0       " Do not lint when leaving insert mode
let g:ale_lint_on_enter = 'never'        " Do not lint when opening the file
let g:ale_lint_on_save = 1               " Do not lint on save (we use Lint())
let g:ale_fix_on_save = 1                " Do not fix on save (we use Lint())

" How to fix
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'json': ['prettier'],
\   'yaml': ['prettier'],
\   'sh': ['shfmt'],
\   'zsh': ['shfmt'],
\}

" How to lint
" By default, Ale runs all linters it knows on all filetypes. I prefer a more
" conservative approach of defining what linters I want to run for each filetype
let g:ale_linters_explicit = 1
let g:ale_linters = {
\   'json': ['jsonlint', 'prettier'],
\   'sh': ['shellcheck'],
\   'vim': ['vint'],
\   'yml': ['yamllint'],
\   'zsh': ['shellcheck'],
\}


let g:ale_sign_error = ' '               " Error sign in gutter
let g:ale_sign_warning = ' '             " Warning sign in gutter
let g:ale_virtualtext_cursor = 'disabled' " Do not display errors in virtual text
