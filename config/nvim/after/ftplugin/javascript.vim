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
" Fixing & Linting {{{
let b:ale_fixers = ['eslint']
" Linting
let b:ale_linters = ['eslint']
" We use global eslint_d instead of local eslint
let b:ale_javascript_eslint_use_global = 1

let b:ale_sign_error = ' '               " Error sign in gutter
" }}}

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
inoremap <buffer> vspo vi.spyOn()i
inoremap <buffer> bfe beforeEach(async () => {});ko
inoremap <buffer> bfa beforeAll(async () => {});ko
inoremap <buffer> iit it('', async () => {<CR>});k2li
inoremap <buffer> iite it.each([[ input, expected ],])('%s', async (input, expected) => {<CR>});2k2l
inoremap <buffer> dsc describe('', () => {});klllllllli
inoremap <buffer> mrv mockReturnValue();hi
inoremap <buffer> thp toHaveProperty('');hhi
inoremap <buffer> thbc toHaveBeenCalled();
inoremap <buffer> thbw toHaveBeenCalledWith();hi
inoremap <buffer> expact expect(actual).a
inoremap <buffer> epxact expect(actual).a
inoremap <buffer> tbt toBe(true);a
inoremap <buffer> tbf toBe(false);a
" Import firost boilerplate
inoremap <buffer> impcone import consoleError from 'firost/consoleError.js';<CR>
inoremap <buffer> impconi import consoleInfo from 'firost/consoleInfo.js';<CR>;
inoremap <buffer> impconw import consoleWarn from 'firost/consoleWarn.js';<CR>;
inoremap <buffer> impemp import emptyDir from 'firost/emptyDir.js';<CR>;
inoremap <buffer> imperr import firostError from 'firost/error.js';<CR>;
inoremap <buffer> impexis import exists from 'firost/exists.js';<CR>;
inoremap <buffer> impexit import exit from 'firost/exit.js';<CR>;
inoremap <buffer> impglo import glob from 'firost/glob.js';<CR>;
inoremap <buffer> impmkd import mkdirp from 'firost/mkdirp.js';<CR>;
inoremap <buffer> impnor import normalizeUrl from 'firost/normalizeUrl.js';<CR>;
inoremap <buffer> impreadj import readJson from 'firost/readJson.js';<CR>;
inoremap <buffer> impread import read from 'firost/read.js';<CR>;
inoremap <buffer> imprun import run from 'firost/run.js';<CR>;
inoremap <buffer> impspi import spinner from 'firost/spinner.js';<CR>;
inoremap <buffer> imptmp import tmpDirectory from 'firost/tmpDirectory.js';<CR>;
inoremap <buffer> impurl import urlToFilepath from 'firost/urlToFilepath.js';<CR>;
inoremap <buffer> impwritej import writeJson from 'firost/writeJson.js';<CR>;
inoremap <buffer> impwritj import writeJson from 'firost/writeJson.js';<CR>;
inoremap <buffer> impwrij import writeJson from 'firost/writeJson.js';<CR>;
inoremap <buffer> impwri import write from 'firost/write.js';<CR>;
" Require golgoth boilerplate
inoremap <buffer> imppmap import pMap from 'golgoth/pMap.js';<CR>;
inoremap <buffer> imp_ import _ from 'golgoth/lodash.js';<CR>;
inoremap <buffer> impday import dayjs from 'golgoth/dayjs.js';<CR>;
inoremap <buffer> impgot import got from 'golgoth/got.js';<CR>;
" Require main modules
inoremap <buffer> imppath import path from 'path';<CR>;
inoremap <buffer> imppat import path from 'path';<CR>;
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
