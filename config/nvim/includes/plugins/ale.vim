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

" When to lint
let g:ale_lint_on_text_changed = 'never' " Do not lint while typing
let g:ale_lint_on_insert_leave = 0       " Do not lint when leaving insert mode
let g:ale_lint_on_enter = 0              " Do not lint when opening the file
let g:ale_fix_on_save = 1                " Fix on save
let g:ale_lint_on_save = 1               " Lint on save

" How to fix
" Note: Language-specific fixers are defined in each ftplugin file
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\}

" How to lint
" By default, Ale runs all linters it knows on all filetypes. I prefer a more
" conservative approach of defining what linters I want to run for each filetype
" Note: Language-specific linters are defined in each ftplugin file
let g:ale_linters_explicit = 1

" How to display errors
" Use ALE-specific UI (not nvim default diagnosis UI, and configure the icons to
" use
let g:ale_use_neovim_diagnostics_api = 0
let g:ale_sign_error = ' '               " Error sign in gutter
let g:ale_sign_warning = ' '             " Warning sign in gutter
let g:ale_virtualtext_cursor = 'disabled' " Do not display errors in virtual text
