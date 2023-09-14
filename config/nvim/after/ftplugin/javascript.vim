" JAVASCRIPT
" Misc {{{
" Indentation rules
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab
" }}}
" Folding {{{
setlocal foldmethod=syntax
setlocal foldlevelstart=99
setlocal foldtext=JavascriptFoldText()
function! JavascriptFoldText()
  let output = getline(v:foldstart)
  let lines = v:foldend - v:foldstart
  let output = substitute(output, '{$', '{...' . lines . '}', '')
  let output = substitute(output, '[$', '[...' . lines . ']', '')
  return output
endfunction
" }}}
" Fixing
let b:ale_fixers = ['eslint']
" Linting
let b:ale_linters = ['eslint']
" We use global eslint_d instead of local eslint
let b:ale_javascript_eslint_use_global = 1

if JavaScriptIsZx()
  let b:ale_javascript_eslint_executable = 'eslint-zx'
else
  let b:ale_javascript_eslint_executable = 'eslint_d'
endif

" Keybindings {{{
" $ù is easy to type on my keyboard. Use it for debug calls
inoremap <buffer> $ù console.info(
" Using ## (as in ruby) for string interpolation
inoremap <buffer> ## ${}<Left>
" Typos I often make
inoremap <buffer> awiat await
" Test boilerplate
inoremap <buffer> jspo jest.spyOn()i
inoremap <buffer> bfe beforeEach(async () => {});ko
inoremap <buffer> bfa beforeAll(async () => {});ko
inoremap <buffer> iit it('', async () => {<CR>});k2li
inoremap <buffer> iite it.each([[ input, expected ],])('%s', async (input, expected) => {<CR>});2k2l
inoremap <buffer> dsc describe('', () => {});klllllllli
inoremap <buffer> mrv mockReturnValue();hi
inoremap <buffer> thp toHaveProperty('');hhi
inoremap <buffer> thbc toHaveBeenCalled();
inoremap <buffer> thbw toHaveBeenCalledWith();hi
" Require firost boilerplate
inoremap <buffer> rqcone const consoleError = require('firost/consoleError');<CR>
inoremap <buffer> rqconi const consoleInfo = require('firost/consoleInfo');<CR>
inoremap <buffer> rqconw const consoleWarn = require('firost/consoleWarn');<CR>
inoremap <buffer> rqemp const emptyDir = require('firost/emptyDir');<CR>
inoremap <buffer> rqerr const firostError = require('firost/error');<CR>
inoremap <buffer> rqexis const exists = require('firost/exists');<CR>
inoremap <buffer> rqexi const exit = require('firost/exit');<CR>
inoremap <buffer> rqglo const glob = require('firost/glob');<CR>
inoremap <buffer> rqmkd const mkdirp = require('firost/mkdirp');<CR>
inoremap <buffer> rqnor const normalizeUrl = require('firost/normalizeUrl');<CR>
inoremap <buffer> rqreadj const readJson = require('firost/readJson');<CR>
inoremap <buffer> rqread const read = require('firost/read');<CR>
inoremap <buffer> rqrun const run = require('firost/run');<CR>
inoremap <buffer> rqspi const spinner = require('firost/spinner');<CR>
inoremap <buffer> rqspin const spinner = require('firost/spinner');<CR>
inoremap <buffer> rqspinn const spinner = require('firost/spinner');<CR>
inoremap <buffer> rqtmp const tmpDirectory = require('firost/tmpDirectory');<CR>
inoremap <buffer> rqurl const urlToFilepath = require('firost/urlToFilepath');<CR>
inoremap <buffer> rqwritej const writeJson = require('firost/writeJson');<CR>
inoremap <buffer> rqwritj const writeJson = require('firost/writeJson');<CR>
inoremap <buffer> rqwrij const writeJson = require('firost/writeJson');<CR>
inoremap <buffer> rqwri const write = require('firost/write');<CR>
" Require golgoth boilerplate
inoremap <buffer> rqpmap const pMap = require('golgoth/pMap');<CR>
inoremap <buffer> rq_ const _ = require('golgoth/lodash');<CR>
inoremap <buffer> rqday const dayjs = require('golgoth/dayjs');<CR>
inoremap <buffer> rqgot const got = require('golgoth/got');<CR>
" Require main modules
inoremap <buffer> rqpath const path = require('path');<CR>
inoremap <buffer> rqpat const path = require('path');<CR>
" JSDoc helpers
inoremap <buffer> @para @param {Array}
inoremap <buffer> @parb @param {boolean}
inoremap <buffer> @parf @param {Function}
inoremap <buffer> @parn @param {number}
inoremap <buffer> @paro @param {object}
inoremap <buffer> @pars @param {string}
inoremap <buffer> @par* @param {*}
inoremap <buffer> @reta @returns {Array}
inoremap <buffer> @retb @returns {boolean}
inoremap <buffer> @retf @returns {Function}
inoremap <buffer> @retn @returns {number}
inoremap <buffer> @reto @returns {object}
inoremap <buffer> @retp @returns {Promise}
inoremap <buffer> @rets @returns {string}
inoremap <buffer> @ret* @returns {*}
inoremap <buffer> @paroa @param {Array} options.
inoremap <buffer> @parob @param {boolean} options.
inoremap <buffer> @parof @param {Function} options.
inoremap <buffer> @paron @param {number} options.
inoremap <buffer> @paroo @param {object} options.
inoremap <buffer> @paros @param {string} options.
inoremap <buffer> @retps @returns {Promise.<string>}
