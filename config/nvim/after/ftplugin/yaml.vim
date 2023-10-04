" YAML
" Fixing
let b:ale_fixers = ['prettier']
" Linting
" We have a specific linter for GitHub Actions workflows
if YamlIsGitHubActions()
  let b:ale_linters = ['actionlint']
else
  let b:ale_linters = ['yamllint']
endif
" Indentation rules {{{
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab
" }}}
" Folding {{{
" The pedrohdz/vim-yaml-folds plugin allows folding to correctly work, but it
" overwrites the foldtext method, so we revert it
set foldtext=OroshiFoldText()
" }}}
