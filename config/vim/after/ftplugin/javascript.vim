" JAVASCRIPT
" Misc {{{
" Indentation rules
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab
setlocal equalprg=eslint_d\ --stdin\ --fix-to-stdout\ -
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
" Linting {{{
let b:syntastic_checkers = ['eslint']
let b:syntastic_javascript_eslint_exec = 'eslint_d'
" }}}
" Cleaning {{{
inoremap <silent> <buffer> <F4> <Esc>:call JavascriptBeautify()<CR><CR>
nnoremap <silent> <buffer> <F4> :call JavascriptBeautify()<CR><CR>
function! JavascriptBeautify() 
  let l:initialLine = line('.')
  execute '%!eslint_d --stdin --fix-to-stdout'
  execute 'normal '.initialLine.'gg'
  SyntasticCheck()
endfunction
" }}}

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
inoremap <buffer> rqcone const consoleError = require('firost/lib/consoleError');<CR>
inoremap <buffer> rqconi const consoleInfo = require('firost/lib/consoleInfo');<CR>
inoremap <buffer> rqconw const consoleWarn = require('firost/lib/consoleWarn');<CR>
inoremap <buffer> rqemp const emptyDir = require('firost/lib/emptyDir');<CR>
inoremap <buffer> rqerr const firostError = require('firost/lib/error');<CR>
inoremap <buffer> rqexis const exist = require('firost/lib/exist');<CR>
inoremap <buffer> rqexi const exit = require('firost/lib/exit');<CR>
inoremap <buffer> rqglo const glob = require('firost/lib/glob');<CR>
inoremap <buffer> rqmkd const mkdirp = require('firost/lib/mkdirp');<CR>
inoremap <buffer> rqnor const normalizeUrl = require('firost/lib/normalizeUrl');<CR>
inoremap <buffer> rqreadj const readJson = require('firost/lib/readJson');<CR>
inoremap <buffer> rqread const read = require('firost/lib/read');<CR>
inoremap <buffer> rqrun const run = require('firost/lib/run');<CR>
inoremap <buffer> rqspi const spinner = require('firost/lib/spinner');<CR>
inoremap <buffer> rqspin const spinner = require('firost/lib/spinner');<CR>
inoremap <buffer> rqspinn const spinner = require('firost/lib/spinner');<CR>
inoremap <buffer> rqtmp const tmpDirectory = require('firost/lib/tmpDirectory');<CR>
inoremap <buffer> rqurl const urlToFilepath = require('firost/lib/urlToFilepath');<CR>
inoremap <buffer> rqwrij const writeJson = require('firost/lib/writeJson');<CR>
inoremap <buffer> rqwritj const writeJson = require('firost/lib/writeJson');<CR>
inoremap <buffer> rqwritej const writeJson = require('firost/lib/writeJson');<CR>
inoremap <buffer> rqwri const write = require('firost/lib/write');<CR>
" Require golgoth boilerplate
inoremap <buffer> rqpmap const pMap = require('golgoth/lib/pMap');<CR>
inoremap <buffer> rq_ const _ = require('golgoth/lib/lodash');<CR>
inoremap <buffer> rqday const dayjs = require('golgoth/lib/dayjs');<CR>
inoremap <buffer> rqgot const got = require('golgoth/lib/got');<CR>
" Require main modules
inoremap <buffer> rqpat const path = require('path');<CR>
" JSDoc helpers
inoremap <buffer> @para @param {Array} 
inoremap <buffer> @parb @param {boolean} 
inoremap <buffer> @parf @param {Function} 
inoremap <buffer> @parn @param {number} 
inoremap <buffer> @paro @param {object} 
inoremap <buffer> @pars @param {string} 
inoremap <buffer> @reta @returns {Array} 
inoremap <buffer> @retb @returns {boolean} 
inoremap <buffer> @retf @returns {Function} 
inoremap <buffer> @retn @returns {number} 
inoremap <buffer> @reto @returns {object} 
inoremap <buffer> @retps @returns {Promise.<string>} 
inoremap <buffer> @retp @returns {Promise} 
inoremap <buffer> @rets @returns {string} 
inoremap <buffer> @retv @returns {void}
